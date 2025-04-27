import 'dart:io';
import 'dart:typed_data';

import 'builder.dart';
import 'gdsii_read_utils.dart';

// GDSII 记录类型枚举（部分常用类型）
enum GdsRecordType {
  /// 版本号
  ///
  /// 2-byte带符号整型
  /// 包含两个字节的数据，代表版本号
  header(0x0002),

  /// 库的开始标记
  ///
  /// 2-byte带符号整型
  /// 包含库的最后修改时间以及上次访问的时间（年，月，日，小时，分钟和秒）。
  bgnlib(0x0102),

  /// 库名
  ///
  /// ASCII 字符串
  libname(0x0206),

  /// 单位
  ///
  /// 8-byte实数型, 包含2个8字节实数
  /// 第一个是以用户为单位的数据库单元的大小
  /// 第二个是数据库单位（data base unit）的大小（以米为单位）
  units(0x0305),

  /// No Data Present
  /// 库的终止标记。
  endlib(0x0400),

  /// 2-byte带符号整型
  /// 结构的创建时间和最后修改时间
  bgnstr(0x0502),

  /// ASCII 字符串
  /// 包含一个字符串，它是结构名称。 结构名称最多可包含32个字符。
  /// 合法结构名称可以包含以下字符：
  /// * [A-Z]
  /// * [a-z]
  /// * [0-9]
  /// * 下划线 _
  /// * 半角问号 ?
  /// * 美元符号 $
  strname(0x0606),

  /// 2-byte带符号整型
  /// 包含结构的创建时间和最后修改时间（与BGNLIB记录的格式相同），
  /// 并标记结构的结束。
  endstr(0x0700),

  /// 作为边界元素的起始标记
  ///
  /// No Data Present
  boundary(0x0800),

  /// 作为路径元素的起始标记
  ///
  /// No Data Present
  path(0x0900),

  /// 作为SREF（Structure reference）元素的起始标记。
  ///
  /// No Data Present
  sref(0x0A00),

  /// 作作为AREF（Array reference）元素的起始标记。
  ///
  /// No Data Present
  aref(0x0B00),

  /// 作为文本元素的起始标记
  ///
  /// No Data Present
  text(0x0C00),

  /// 2-byte带符号整型
  /// 包含两个字节，用于指定图层。
  /// 图层的值必须在O-63的范围内。
  layer(0x0D02),

  /// 2-byte带符号整型
  /// 包含两个字节，用于指定数据类型。
  /// 数据类型的值必须在O-63的范围内。
  datatype(0x0E02),

  /// 4-byte带符号整型
  /// 包含四个字节，这些字节以据库单位为单位指定路径或文本行的宽度。
  /// 负值表示宽度是绝对的，即不受任何父参考的放大倍数的影响。
  /// 如果省略，则假定为零
  width(0x0F03),

  /// 4-byte带符号整型
  /// 包含以据库单位为单位的XY坐标数组
  /// 每个X或Y坐标长四个字节
  ///
  /// 路径和边界元素最多可具有200对坐标。
  /// 路径必须具有至少2对坐标，边界必须具有至少4对坐标。
  /// 边界的第一个点和最后一个点必须重合。
  ///
  /// 文本或SREF元素必须只有一对坐标。
  ///
  /// AREF恰好具有三对坐标，它们指定了正交数组晶格。
  /// 在AREF中，第一个点是数组参考点。
  /// 第二点位于一个位置，该位置与参考点的距离为列间间距乘以列数。
  /// 第三点定位的位置与参考点的距离为行间距乘以行数。
  ///
  /// 一个node可能具有1到50对坐标。
  ///
  /// 一个box必须具有五对坐标，且第一点和最后一点重合。
  xy(0x1003),

  /// No Data Present
  /// 作为元素的终止标记。
  endel(0x1100),

  /// ASCII 字符串
  /// 包含引用结构的名称。
  /// 另请参阅STRNAME。
  sname(0x1206),

  /// 2-byte带符号整型
  /// 包含4个字节, 前2个字节包含数组中的列数, 第三和第四字节包含行数。
  /// 列数和行数都不得超过32,767（十进制），并且两者均为正数。
  colrow(0x1302),

  /// No Data Present
  /// 标记文本节点的开头（当前未使用的）。
  textnode(0x1400),

  /// No Data Present
  /// 作为节点开头的标记。
  node(0x1500),

  /// 2-byte带符号整型
  /// 包含2个字节，表示文本类型。
  /// 文本类型的值必须在O-63的范围内。
  texttype(0x1602),

  /// 2-byte带符号整型
  /// 包含1个字符（2个字节）的位标记符，用于表示文本。
  /// 第10和11位一起作为一个二进制数以指定字体. 00表示字体大小0，01表示字体大小1，10表示字体大小2，11表示字体大小3。
  /// 第12和13位指定垂直对其（00表示顶部，01表示中间，而10表示底部）。
  /// 位14和15指定水平对其（00表示左，01表示中心，而10表示右）。
  /// O到9位保留供将来使用，必须清零。
  /// 如果省略此记录，则默认左上对齐和字体大小O。
  presentation(0x1701),

  /// Discontinued
  // spacing(),

  /// ASCII 字符串
  /// 包含用于文本展示的字符串，最长512个字符。
  string(0x1906),

  /// 位数组
  /// 作为节点开头的标记。
  /// 包含两个字节的针对“SREF，AREF和TEXT”的空间变换标识符。
  /// 0位（最左边的位）指定是否镜像。
  /// 如果设置镜像，则将在绕角旋转之前先以X轴为基准进行镜像。
  ///
  /// 对于AREF，则以整个阵列点阵为基准进行镜像，而不是针对每个阵列元素进行镜像。
  ///
  /// 第13位标记绝对放大率。
  /// 第14位标记绝对角度。
  /// 第15位（最右边的位）和所有其余位保留供将来使用，必须将其清除。
  /// 如果省略此记录，则假定该元素没有镜像，并且假定其放大倍率和旋转角度均非绝对。
  strans(0x1A01),

  /// 8-byte实数型
  /// 包含一个双精度实数（8个字节），它是放大倍数。
  /// 如果省略，则默认放大倍数为1。
  mag(0x1B05),

  /// 8-byte实数型
  /// 包含一个双精度实数（8个字节），它是角度旋转因子（单位：度），以逆时针方向为正。
  /// 对于AREF，“角度”将围绕阵列基准点旋转整个阵列网格各个阵列元素之间的相对位置不变。
  /// 如果省略此记录，则假定角度为零度。
  angle(0x1C05),

  ///  User Integer(不再被使用)
  /// 用户字符串数据(以前称为字符串数据(CSD))曾在1.0和2.0版中被使用。
  /// 如果将这些发行版中的任何流格式文件读入当前软件，
  /// 则流格式输入程序INFORM会将用户字符串数据转换为属性编号为127的属性数据。
  /// 如果该记录不存在，则为空字符串。 另请参见PROPATTR和PROPVALUE。
  // uinteger(),

  /// User String(不再被使用)
  /// 用户字符串数据(以前称为字符串数据(CSD))曾在1.0和2.0版中被使用。
  /// 如果将这些发行版中的任何流格式文件读入当前软件，
  /// 则流格式输入程序INFORM会将用户字符串数据转换为属性编号为127的属性数据。
  /// 如果该记录不存在，则为空字符串。 另请参见PROPATTR和PROPVALUE。
  // ustring(),

  /// ASCII 字符串
  /// 包含参考库的名称。 如果有任何引用库绑定到当前库，则该记录必须存在。
  /// 第一个参考库的名称从字节0开始，第二个库的名称从字节45（十进制）开始。
  /// 参考库名称可能包括目录说明符（以“:”分隔）和扩展名（以“.”分隔）。
  /// 如果未命名任何一个库，则其位置将填充为空。
  reflibs(0x1F06),

  /// ASCII 字符串
  /// 包含textfont定义文件的名称。
  /// 如果4种字体中的任何一种具有相应的textfont定义文件，则必须存在此记录。
  /// 如果所有字体都没有textfont定义文件，则该记录不能存在。
  /// 字体0的名称开始记录，然后是其余3种字体。
  /// 每个名称的长度为44个字节，如果没有相应的文本字体定义则为null。
  /// 如果每个名称短于44个字节，则用空值填充。
  /// textfont定义文件名可能包含目录说明符（以“:”分隔）和扩展名（以“.”分隔）。
  fonts(0x2006),

  /// 2-byte带符号整型
  /// 对于与端点齐平结束的方端路径，此记录值为0；
  /// 对于圆端路径，此记录值为1；
  /// 对于超出端点一半宽度的方端路径，此记录值为2。
  /// 路径类型4(仅适用于CustomPlus产品)表示具有可变方头扩展名的路径(参见记录48和49)。
  /// 如果未指定，则假定路径类型为0。
  pathtype(0x2102),

  /// 2-byte带符号整型
  /// 该记录包含要保留的已删除或备份结构的副本数的正数。
  /// 此数字必须大于等于2且小于等于99。
  /// 如果不存在GENERATIONS记录，则默认值为3。
  generations(0x2202),

  /// ASCII 字符串
  /// 包含属性定义文件的名称。
  /// 仅当存在绑定到库的属性定义文件时，此记录才存在。
  /// 属性定义文件名可以包括目录说明符（用“:”分隔）和扩展名（用“.”分隔）。
  /// 最大大小为44个字节。
  attrtable(0x2306),

  /// ASCII 字符串
  /// 新特性，暂未释出
  styptable(0x2406),

  /// 2-byte带符号整型
  /// 新特性，暂未释出
  strtype(0x2502),

  /// 位数组
  /// 包含2个字节的位标志。
  /// 第15位（最右边的位）指定模板数据。
  /// 第14位指定外部数据（也称为外部数据）。
  /// 所有其他位当前未使用，必须清除为0。
  /// 如果省略此记录，则所有位均默认为0。
  ///
  /// 有关模板数据的其他信息，请参阅《GDSII参考手册》。
  /// 有关外部数据的其他信息，请参阅《CustomPlus用户手册》。
  elflags(0x2601),

  /// 4-byte带符号整型
  /// 新特性，暂未释出
  elkey(0x2703),

  /// 4-byte带符号整型
  /// 新特性，暂未释出
  linktype(0x28),

  /// 4-byte带符号整型
  /// 新特性，暂未释出
  linkkeys(0x29),

  /// 2-byte带符号整型
  /// 包含2个字节，用于指定节点类型。
  /// 节点类型的值必须在0到63的范围内。
  nodetype(0x2A02),

  /// 2-byte带符号整型
  /// 包含2个字节，用于指定属性编号。
  /// 属性号是1到127之间的整数。
  /// 属性号126和127保留给版本3.0之前存在的用户整数和用户字符串（CSD）属性。
  /// (以前的版本中的用户字符串和用户整数数据通过流格式输入
  /// 程序INFORM转换为属性编号为127和126的属性数据。)
  propattr(0x2B02),

  /// 2-byte带符号整型
  /// 包含与前面的PROPATTR记录中命名的属性关联的字符串值。
  /// 最大长度为126个字符。
  /// 与任何一个元素关联的属性值对必须全部具有不同的属性编号。
  /// 此外，对与任何一个元素相关联的属性数据的总量也有一个限制：
  /// 所有字符串的总长度加上属性值对的数量的两倍，不得超过128
  /// （如果该元素为512，是SREF，AREF或节点）。
  ///
  /// 例如，如果边界元素使用属性值为2的属性属性2和属性值为10的属性属性10，
  /// 则属性数据的总量将为18个字节。
  /// 这是6个字节的“金属”(奇数长度的字符串必须用空值填充) + 8个“属性”+2倍于2个属性(4)=18。
  propvalue(0x2C06),

  /// No Data Present
  /// 作为Box元素的起始标记
  box(0x2D00),

  /// 2-byte带符号整型
  /// 包含2个字节，用于指定boxtype。
  /// boxtype的值必须在0-63的范围内。
  boxtype(0x2E02),

  /// 4-byte带符号整型
  /// 该元素所属的plex下的所有元素共有的唯一正数（标识符）。
  /// 通过设置第七位来标记plex的头部. 因此，plex数应足够小以仅占据最右边的24位。
  /// 如果省略此记录，则该元素不是plex成员。
  plex(0x2f03),

  /// Character String(不再被使用)
  /// 适用于PATH类型4。
  /// 包含四个字节，以数据库单位指定路径轮廓超出路径第一点的扩展。
  /// 值可以为负。
  bgnextn(0x3003),

  /// 4-byte带符号整型(此记录类型仅能在CustomPlus中存在。)
  /// 适用于PATH类型4。
  /// 包含四个字节，以数据库单位指定路径轮廓超出路径最后一点的扩展。 值可以为负。
  endextn(0x3103),

  /// 2-byte带符号整型
  /// 包含两个字节，用于指定多卷流文件的当前卷带数。
  /// 对于第一个磁带，TAPENUM为1； 对于第二个磁带，TAPENUM为2； 以此类推。
  tapenum(0x3202),

  /// 2-byte带符号整型
  /// 包含12个字节。
  /// 对于多卷流文件的所有卷的标识符（同一个流文件的标识符在多卷中相同）。
  /// 它验证是否正在读取正确的卷轴。
  tapecode(0x3302);

  final int value;

  const GdsRecordType(this.value);

  static GdsRecordType? normalize(int value) {
    for (final GdsRecordType type in GdsRecordType.values) {
      if (type.value == value) return type;
    }

    return null;
  }
}

class TempCell {
  late String name;

  late DateTime lastModificationTime;

  late DateTime lastAccessTime;

  late List<Struct> srefs = [];
}

class Cell {
  Cell({required this.name, required this.lastModificationTime, required this.lastAccessTime, required this.srefs});

  final String name;

  final DateTime lastModificationTime;

  final DateTime lastAccessTime;

  final List<Struct> srefs;
}

class Gdsii {
  Gdsii({
    required this.version,
    required this.lastModificationTime,
    required this.lastAccessTime,
    required this.libname,
    required this.units,
    required this.cells,
  });

  final int version;

  final DateTime lastModificationTime;

  final DateTime lastAccessTime;

  final String libname;

  final double units;

  final List<Cell> cells;

  void console() {
    print("version: $version");
    print("lastModificationTime: $lastModificationTime");
    print("lastAccessTime: $lastAccessTime");
    print("libname: $libname");
    print("units: $units");
  }
}

Gdsii readGdsii(String path) {
  final file = File(path);
  late int version;
  late DateTime lastModificationTime;
  late DateTime lastAccessTime;
  late String libname;
  late double units;

  late StructBuilder builder;
  List<TempCell> tempCells = [];

  for (final (GdsRecordType type, ByteData data) in recordReader(file)) {
    final _ = switch (type) {
      GdsRecordType.header =>
        (() {
          version = data.getInt16(0);
        })(),
      GdsRecordType.bgnlib =>
        (() {
          (lastModificationTime, lastAccessTime) = readTime(data);
        })(),
      GdsRecordType.libname =>
        (() {
          libname = readString(data);
        })(),
      GdsRecordType.units =>
        (() {
          units = readf64(data);
        })(),
      GdsRecordType.bgnstr => // Cell 开始
        (() {
          final bgnstr = readTime(data);
          final TempCell tempCell = TempCell();
          tempCell.lastModificationTime = bgnstr.$1;
          tempCell.lastAccessTime = bgnstr.$2;
          tempCells.add(tempCell);
        })(),
      GdsRecordType.strname => // Cell 名称
        (() {
          final strname = readString(data);
          tempCells.last.name = strname;
        })(),

      GdsRecordType.box =>
        (() {
          print("box");
          // builder = BoundaryStructBuilder();
        })(),
      GdsRecordType.node =>
        (() {
          print("node");
          // builder = BoundaryStructBuilder();
        })(),
      GdsRecordType.text =>
        (() {
          builder = TextStructBuilder();
        })(),
      GdsRecordType.boundary =>
        (() {
          builder = BoundaryStructBuilder();
        })(),
      GdsRecordType.path =>
        (() {
          builder = PathStructBuilder();
        })(),
      GdsRecordType.sref =>
        (() {
          builder = SRefStructBuilder();
        })(),
      GdsRecordType.aref =>
        (() {
          builder = ARefStructBuilder();
        })(),

      GdsRecordType.endel => // 元素结束
        (() {
          final value = builder.build();
          tempCells.last.srefs.add(value);
        })(),
      GdsRecordType.endstr => // Cell 结构结束
        (() {
          // print("endstr");
        })(),
      GdsRecordType.endlib =>
        (() {
          // print("endlib");
        })(),
      (GdsRecordType other) =>
        (() {
          builder.handle(other, data);
        })(),
    };
  }

  final cells = tempCells
      .map((item) {
        return Cell(name: item.name, lastModificationTime: item.lastModificationTime, lastAccessTime: item.lastAccessTime, srefs: item.srefs);
      })
      .toList(growable: false);

  return Gdsii(version: version, lastModificationTime: lastModificationTime, lastAccessTime: lastAccessTime, libname: libname, units: units, cells: cells);
}
