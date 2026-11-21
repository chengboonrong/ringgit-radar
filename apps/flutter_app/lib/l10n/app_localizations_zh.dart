// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get languageHeading => '语言';

  @override
  String get appLanguageSystem => '跟随系统';

  @override
  String couldNotLoad(String what) {
    String _temp0 = intl.Intl.selectLogic(what, {
      'list': '无法载入列表。',
      'highlights': '无法载入精选。',
      'ranking': '无法载入排行。',
      'genres': '无法载入游戏类型。',
      'status': '无法载入数据状态。',
      'game': '无法载入这款游戏。',
      'other': '无法载入。',
    });
    return '$_temp0';
  }

  @override
  String serverAnswered(int status) {
    return '服务器返回了代码 $status。';
  }

  @override
  String get serverUnreachable => '无法连接 Ringgit Radar 服务器。';

  @override
  String get unexpectedAnswer => '服务器返回的数据格式不对。';

  @override
  String get somethingWentWrong => '出了点问题。';

  @override
  String saleEnds(String dateTime) {
    return '特价截止：$dateTime';
  }

  @override
  String percentOff(int percent) {
    return '省$percent%';
  }

  @override
  String itemsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $countString 项',
    );
    return '$_temp0';
  }

  @override
  String get comingSoon => '即将发售';

  @override
  String get priceUnavailable => '暂无价格';

  @override
  String get navHighlights => '精选';

  @override
  String get navSearch => '搜索';

  @override
  String get navWishList => '愿望单';

  @override
  String get navSale => '特价';

  @override
  String get navRanking => '排行';

  @override
  String get navRecent => '新近发售';

  @override
  String get navComingSoon => '即将发售';

  @override
  String get aboutApp => '关于 Ringgit Radar';

  @override
  String get sections => '栏目';

  @override
  String get retry => '重试';

  @override
  String get kindBundle => '套装';

  @override
  String get kindAddon => '追加内容';

  @override
  String get kindGame => '游戏';

  @override
  String get statusPreorder => '预购';

  @override
  String get statusNew => '新品';

  @override
  String rankN(int rank) {
    return '第 $rank 名';
  }

  @override
  String endsOn(String date) {
    return '$date截止';
  }

  @override
  String wishRemove(String title) {
    return '把 $title 移出愿望单';
  }

  @override
  String wishAdd(String title) {
    return '把 $title 加入愿望单';
  }

  @override
  String priceOnSaleDescription(String now, String was, int percent) {
    return '特价 $now，原价 $was，省 $percent%';
  }

  @override
  String get back => '返回';

  @override
  String mediaPosition(int index, int count) {
    return '图片，第 $index 张，共 $count 张';
  }

  @override
  String get nextImage => '下一张';

  @override
  String get previousImage => '上一张';

  @override
  String get noPriceYet => '还没有价格记录。';

  @override
  String trackingBeganOnlyPrice(String date) {
    return '$date开始记录。到目前为止，我们只见过这个价格。';
  }

  @override
  String lowestSeenSince(String price, String date) {
    return '我们见过的最低价：$price，$date首次出现';
  }

  @override
  String trackingBegan(String date) {
    return '$date开始记录';
  }

  @override
  String get historyHeading => '我们的价格记录';

  @override
  String priceHistorySummary(String date, String prices) {
    return '自$date起的价格记录：$prices。';
  }

  @override
  String get priceHistoryJoiner => '，之后 ';

  @override
  String get descriptionHeading => '简介';

  @override
  String get dlcHeading => '可下载内容';

  @override
  String get publisher => '发行商';

  @override
  String get platform => '平台';

  @override
  String get productTypeDetail => '产品类型';

  @override
  String get releaseDate => '发售日期';

  @override
  String get genre => '游戏类型';

  @override
  String get players => '玩家人数';

  @override
  String get detailsHeading => '详细信息';

  @override
  String get noAgeRating => '未找到年龄分级';

  @override
  String ageRating(int age) {
    return '年龄分级：$age（UK PEGI）';
  }

  @override
  String get onWishList => '已在愿望单';

  @override
  String get addToWishList => '加入愿望单';

  @override
  String get buyOnSwitch => '请在你的 Switch 上通过 Nintendo eShop 购买。';

  @override
  String get biggestSwitch2Savings => 'Switch 2 节省金额最高';

  @override
  String get endingSoonHeading => '即将截止';

  @override
  String get newSales => '新特价';

  @override
  String upToRm(int amount) {
    return 'RM $amount 以下';
  }

  @override
  String showResults(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '显示 $countString 个结果',
    );
    return '$_temp0';
  }

  @override
  String get showResultsNoCount => '显示结果';

  @override
  String get closeFilters => '关闭筛选';

  @override
  String get backToFilters => '返回筛选';

  @override
  String get clear => '清除';

  @override
  String get filterProductType => '产品类型';

  @override
  String get filterPrice => '特价 / 价格上限';

  @override
  String get filterAge => '年龄分级';

  @override
  String get filter => '筛选';

  @override
  String filterCount(int count) {
    return '筛选（$count）';
  }

  @override
  String filterSelected(int count) {
    return '筛选，已选 $count 项';
  }

  @override
  String ageN(int age) {
    return '年龄 $age（UK PEGI）';
  }

  @override
  String get ageNote => '未找到分级的游戏会留在列表里，直到你选择年龄。';

  @override
  String get onSaleOnly => '只看特价';

  @override
  String get nothingHere => '这里还没有内容。';

  @override
  String get retryLoadingMore => '重新载入更多';

  @override
  String get sortOrder => '排序方式';

  @override
  String sortCurrent(String label) {
    return '排序：$label';
  }

  @override
  String get sortSavings => '节省金额最高';

  @override
  String get sortDiscount => '折扣最大';

  @override
  String get sortPrice => '价格最低';

  @override
  String get sortNewest => '最新';

  @override
  String get sortEnding => '即将截止';

  @override
  String get sortTitle => '名称';

  @override
  String get sortSoonest => '最早发售';

  @override
  String get saleHint => '特价截止时间均为马来西亚时间。';

  @override
  String get comingSoonHint => '发售日期取自商店页面。';

  @override
  String get noFilterMatch => '没有符合这些筛选条件的游戏。清除一项筛选可以看到更多。';

  @override
  String get rankedBySaved => '按省下的令吉排序';

  @override
  String get nothingOnSaleConsole => '这台主机目前没有特价游戏。';

  @override
  String get someProductsMissing => '部分产品可能未收录。';

  @override
  String get noTitlesFound => '没有找到游戏。试试别的关键词，或清除一项筛选。';

  @override
  String get searchHint => '按关键词或名称搜索';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get viewAllSoftware => '查看全部软件';

  @override
  String get switch2ViewAll => 'Switch 2，查看全部软件';

  @override
  String genreGames(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name，$countString 款游戏',
    );
    return '$_temp0';
  }

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutUnofficial => 'Ringgit Radar 是一款独立的非官方应用，与任天堂无关，也未获其认可。';

  @override
  String get aboutRecord => '本应用保存自己的马来西亚 eShop 令吉价格记录。要购买游戏，请使用你的 Switch。';

  @override
  String get privacy => '隐私';

  @override
  String get dataHeading => '数据';

  @override
  String get pricesLastChecked => '上次查看价格';

  @override
  String get notYet => '暂无';

  @override
  String malaysiaTime(String dateTime) {
    return '$dateTime（马来西亚时间）';
  }

  @override
  String get trackingBeganLabel => '开始记录于';

  @override
  String get productsTracked => '记录的产品数';

  @override
  String get appearanceHeading => '外观';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get listsHeading => '列表';

  @override
  String get showAllTitles => '显示全部游戏';

  @override
  String get showAllSubtitle => '也列出默认隐藏的游戏，例如因关键词被标记的游戏。';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get privacyNoAccountsTitle => '无需账户';

  @override
  String get privacyNoAccountsBody =>
      '无需登录。Ringgit Radar 不会询问你的姓名、电邮或电话号码，也没有广告和数据分析。';

  @override
  String get privacyDeviceTitle => '你的愿望单只保存在你的设备上';

  @override
  String get privacyDeviceBody =>
      '你的愿望单、主题和语言选择以及“显示全部游戏”设置只保存在这台设备上：网页版保存在浏览器的本地存储中，Android 应用保存在应用的偏好设置中。打开愿望单时，应用会按游戏编号向我们的服务器请求这些游戏，因此服务器会在这次请求中收到这些编号，以便作出回应。服务器不会保存这些编号，也不会把它们与你关联。';

  @override
  String get privacyLogsTitle => '我们的服务器记录什么';

  @override
  String get privacyLogsBody =>
      '我们的服务器不写访问日志。它只记录错误，例如数据库错误，这些记录只包含错误信息，不包含你的网络地址。为了防止单一访客使服务器过载，服务器会按网络地址计算请求次数，这些计数只保存在内存中。这些地址从不写入磁盘。';

  @override
  String get privacyPicturesTitle => '图片来自任天堂的图片服务器';

  @override
  String get privacyPicturesBody =>
      '游戏封面和截图直接从商店的图片服务器（img-eshop.cdn.nintendo.net）载入。你的浏览器或手机会向它请求每张图片，因此任天堂会收到你的网络地址和一般的请求信息，适用任天堂自己的隐私政策。Ringgit Radar 不保存也不转交任何图片。';

  @override
  String get privacyOthersTitle => '还有谁会看到你的访问';

  @override
  String get privacyOthersBody =>
      '网站及其服务器运行在 Vercel 上。Vercel 按其自己的政策保存请求日志，其中可能包括你请求的页面、时间、你的网络地址和浏览器类型。价格数据存放在 Supabase；那里只有游戏价格，没有任何访客信息，而且只接收我们服务器的请求。除了那些图片，网页版的所有内容（包括字体）都从我们自己的地址载入，Android 应用也只与我们的服务器通信。';

  @override
  String get privacyNotNintendoTitle => '不是任天堂';

  @override
  String get privacyNotNintendoBody =>
      'Ringgit Radar 是一款独立的非官方应用，与任天堂无关，也未获其认可。价格收集自马来西亚 Nintendo eShop，并与其历史价格一同显示；要购买游戏，请使用你的 Switch。';

  @override
  String get privacyEnglishPrevails => '本页为英文版的翻译；如两者有出入，以英文版为准。';

  @override
  String get backToAbout => '返回关于';

  @override
  String get onSaleChip => '特价';

  @override
  String get noneOnSale => '你的愿望单里目前没有特价游戏。';

  @override
  String get wishEmptyTitle => '你可以把感兴趣的软件加入愿望单！';

  @override
  String get wishEmptyHint => '在列表里或游戏页面上点一下任何游戏的心形图标，就能把它加到这里。';

  @override
  String get genreAction => '动作';

  @override
  String get genreAdventure => '冒险';

  @override
  String get genrePuzzle => '益智';

  @override
  String get genreSimulation => '模拟';

  @override
  String get genreArcade => '街机';

  @override
  String get genreRpg => '角色扮演';

  @override
  String get genreStrategy => '策略';

  @override
  String get genreOther => '其他';

  @override
  String get genrePlatformer => '平台跳跃';

  @override
  String get genreShooter => '射击';

  @override
  String get genreParty => '派对';

  @override
  String get genreMultiplayer => '多人游戏';

  @override
  String get genreRacing => '竞速';

  @override
  String get genreSports => '体育';

  @override
  String get genreBoardGame => '桌游';

  @override
  String get genreFighting => '格斗';

  @override
  String get genreLifestyle => '生活方式';

  @override
  String get genreCommunication => '交流';

  @override
  String get genreEducation => '教育';

  @override
  String get genreTraining => '训练';

  @override
  String get genreStudy => '学习';

  @override
  String get genreUtility => '实用工具';

  @override
  String get genreFirstPersonShooter => '第一人称射击';

  @override
  String get genreMusic => '音乐';

  @override
  String get genrePractical => '实用软件';

  @override
  String get genreVideo => '视频';
}
