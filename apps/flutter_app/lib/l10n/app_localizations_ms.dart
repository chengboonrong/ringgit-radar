// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get languageHeading => 'Bahasa';

  @override
  String get appLanguageSystem => 'Ikut sistem';

  @override
  String couldNotLoad(String what) {
    String _temp0 = intl.Intl.selectLogic(what, {
      'list': 'Senarai tidak dapat dimuatkan.',
      'highlights': 'Sorotan tidak dapat dimuatkan.',
      'ranking': 'Kedudukan tidak dapat dimuatkan.',
      'genres': 'Genre tidak dapat dimuatkan.',
      'status': 'Status data tidak dapat dimuatkan.',
      'game': 'Permainan ini tidak dapat dimuatkan.',
      'other': 'Tidak dapat dimuatkan.',
    });
    return '$_temp0';
  }

  @override
  String serverAnswered(int status) {
    return 'Pelayan membalas dengan kod $status.';
  }

  @override
  String get serverUnreachable =>
      'Pelayan Ringgit Radar tidak dapat dihubungi.';

  @override
  String get unexpectedAnswer =>
      'Jawapan pelayan tidak dalam bentuk yang dijangka.';

  @override
  String get somethingWentWrong => 'Ada sesuatu yang tidak kena.';

  @override
  String saleEnds(String dateTime) {
    return 'Promosi sehingga $dateTime';
  }

  @override
  String percentOff(int percent) {
    return 'DISKAUN $percent%';
  }

  @override
  String itemsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Item: $countString',
    );
    return '$_temp0';
  }

  @override
  String get comingSoon => 'Akan datang';

  @override
  String get priceUnavailable => 'Tiada harga';

  @override
  String get navHighlights => 'Sorotan';

  @override
  String get navSearch => 'Cari';

  @override
  String get navWishList => 'Senarai Hajat';

  @override
  String get navSale => 'Promosi';

  @override
  String get navRanking => 'Kedudukan';

  @override
  String get navRecent => 'Keluaran Terkini';

  @override
  String get navComingSoon => 'Akan Datang';

  @override
  String get aboutApp => 'Perihal Ringgit Radar';

  @override
  String get sections => 'Bahagian';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get kindBundle => 'Pakej';

  @override
  String get kindAddon => 'Kandungan tambahan';

  @override
  String get kindGame => 'Permainan';

  @override
  String get statusPreorder => 'Pra-tempah';

  @override
  String get statusNew => 'BAHARU';

  @override
  String rankN(int rank) {
    return 'Kedudukan $rank';
  }

  @override
  String endsOn(String date) {
    return 'Hingga $date';
  }

  @override
  String wishRemove(String title) {
    return 'Buang $title daripada Senarai Hajat';
  }

  @override
  String wishAdd(String title) {
    return 'Tambah $title ke Senarai Hajat';
  }

  @override
  String priceOnSaleDescription(String now, String was, int percent) {
    return 'Harga promosi $now, harga asal $was, diskaun $percent peratus';
  }

  @override
  String get back => 'Kembali';

  @override
  String mediaPosition(int index, int count) {
    return 'Media, $index daripada $count';
  }

  @override
  String get nextImage => 'Gambar seterusnya';

  @override
  String get previousImage => 'Gambar sebelumnya';

  @override
  String get noPriceYet => 'Belum ada harga direkodkan.';

  @override
  String trackingBeganOnlyPrice(String date) {
    return 'Rekod bermula $date. Setakat ini kami hanya pernah melihat harga ini.';
  }

  @override
  String lowestSeenSince(String price, String date) {
    return 'Harga terendah yang pernah kami lihat: $price sejak $date';
  }

  @override
  String trackingBegan(String date) {
    return 'Rekod bermula $date';
  }

  @override
  String get historyHeading => 'Apa yang ditunjukkan rekod kami';

  @override
  String priceHistorySummary(String date, String prices) {
    return 'Sejarah harga sejak $date: $prices.';
  }

  @override
  String get priceHistoryJoiner => ', kemudian ';

  @override
  String get descriptionHeading => 'Keterangan';

  @override
  String get dlcHeading => 'Kandungan Boleh Muat Turun';

  @override
  String get publisher => 'Penerbit';

  @override
  String get platform => 'Platform';

  @override
  String get productTypeDetail => 'Jenis produk';

  @override
  String get releaseDate => 'Tarikh keluaran';

  @override
  String get genre => 'Genre';

  @override
  String get players => 'Bilangan pemain';

  @override
  String get detailsHeading => 'Butiran';

  @override
  String get onWishList => 'Disimpan';

  @override
  String get addToWishList => '+ Senarai Hajat';

  @override
  String get buyOnSwitch => 'Beli di Nintendo eShop pada Switch anda.';

  @override
  String get biggestSwitch2Savings => 'Penjimatan Switch 2 terbesar';

  @override
  String get endingSoonHeading => 'Hampir Tamat';

  @override
  String get newSales => 'Promosi Baharu';

  @override
  String upToRm(int amount) {
    return 'Hingga RM $amount';
  }

  @override
  String showResults(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tunjuk $countString hasil',
      one: 'Tunjuk 1 hasil',
    );
    return '$_temp0';
  }

  @override
  String get showResultsNoCount => 'Tunjuk hasil';

  @override
  String get closeFilters => 'Tutup penapis';

  @override
  String get backToFilters => 'Kembali ke penapis';

  @override
  String get clear => 'Set semula';

  @override
  String get filterProductType => 'Jenis Produk';

  @override
  String get filterPrice => 'Promosi / Had Harga';

  @override
  String get filter => 'Tapis';

  @override
  String filterCount(int count) {
    return 'Tapis ($count)';
  }

  @override
  String filterSelected(int count) {
    return 'Tapis, $count dipilih';
  }

  @override
  String get onSaleOnly => 'Promosi sahaja';

  @override
  String get nothingHere => 'Belum ada apa-apa di sini.';

  @override
  String get retryLoadingMore => 'Cuba muatkan lagi';

  @override
  String get sortOrder => 'Susunan isihan';

  @override
  String sortCurrent(String label) {
    return 'Isih: $label';
  }

  @override
  String get sortSavings => 'Penjimatan terbesar';

  @override
  String get sortDiscount => 'Diskaun terbesar';

  @override
  String get sortPrice => 'Harga terendah';

  @override
  String get sortNewest => 'Terbaharu';

  @override
  String get sortEnding => 'Hampir tamat';

  @override
  String get sortTitle => 'Tajuk';

  @override
  String get sortSoonest => 'Paling awal';

  @override
  String get saleHint =>
      'Tarikh tamat promosi ditunjukkan dalam waktu Malaysia.';

  @override
  String get comingSoonHint =>
      'Tarikh keluaran diambil daripada halaman kedai.';

  @override
  String get noFilterMatch =>
      'Tiada tajuk sepadan dengan penapis ini. Buang satu penapis untuk melihat lebih banyak.';

  @override
  String get rankedBySaved => 'Disusun mengikut ringgit yang dijimatkan';

  @override
  String get nothingOnSaleConsole => 'Tiada promosi untuk konsol ini sekarang.';

  @override
  String get someProductsMissing =>
      'Sesetengah produk mungkin tidak disenaraikan.';

  @override
  String get noTitlesFound =>
      'Tiada tajuk ditemui. Cuba kata kunci lain, atau buang satu penapis.';

  @override
  String get searchHint => 'Cari ikut kata kunci/tajuk';

  @override
  String get clearSearch => 'Kosongkan carian';

  @override
  String get viewAllSoftware => 'Lihat Semua Perisian';

  @override
  String get switch2ViewAll => 'Switch 2, Lihat Semua Perisian';

  @override
  String genreGames(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, $countString permainan',
      one: '$name, 1 permainan',
    );
    return '$_temp0';
  }

  @override
  String get aboutTitle => 'Perihal';

  @override
  String get aboutUnofficial =>
      'Ringgit Radar ialah aplikasi bebas yang tidak rasmi. Ia tiada hubungan dengan Nintendo dan tidak diiktiraf oleh Nintendo.';

  @override
  String get aboutRecord =>
      'Ia menyimpan rekodnya sendiri tentang harga eShop Malaysia dalam ringgit. Untuk membeli permainan, gunakan Switch anda.';

  @override
  String get privacy => 'Privasi';

  @override
  String get dataHeading => 'Data';

  @override
  String get pricesLastChecked => 'Harga terakhir disemak';

  @override
  String get notYet => 'Belum';

  @override
  String malaysiaTime(String dateTime) {
    return '$dateTime (waktu Malaysia)';
  }

  @override
  String get trackingBeganLabel => 'Rekod bermula';

  @override
  String get productsTracked => 'Produk direkodkan';

  @override
  String get appearanceHeading => 'Penampilan';

  @override
  String get themeSystem => 'Ikut sistem';

  @override
  String get themeLight => 'Cerah';

  @override
  String get themeDark => 'Gelap';

  @override
  String get listsHeading => 'Senarai';

  @override
  String get showAllTitles => 'Tunjuk semua tajuk';

  @override
  String get showAllSubtitle =>
      'Turut menyenaraikan tajuk yang tersembunyi secara lalai, seperti yang ditanda kerana kata kunci.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get privacyNoAccountsTitle => 'Tiada akaun';

  @override
  String get privacyNoAccountsBody =>
      'Tiada log masuk. Ringgit Radar tidak meminta nama, e-mel atau nombor telefon anda, dan ia tidak mempunyai iklan atau analitik.';

  @override
  String get privacyDeviceTitle => 'Senarai Hajat anda kekal pada peranti anda';

  @override
  String get privacyDeviceBody =>
      'Senarai Hajat anda, pilihan tema dan bahasa anda serta tetapan \"Tunjuk semua tajuk\" disimpan pada peranti ini sahaja: dalam storan setempat pelayar di web, dalam keutamaan aplikasi di Android. Apabila anda membuka Senarai Hajat, aplikasi meminta permainan-permainan itu daripada pelayan kami mengikut id permainan, jadi pelayan menerima id tersebut dalam permintaan itu untuk menjawabnya. Pelayan tidak menyimpan id itu atau mengaitkannya dengan anda.';

  @override
  String get privacyLogsTitle => 'Apa yang dilog oleh pelayan kami';

  @override
  String get privacyLogsBody =>
      'Pelayan kami tidak menulis log akses. Ia hanya melog ralat, contohnya ralat pangkalan data, dan baris log tersebut mengandungi mesej ralat, bukan alamat internet anda. Untuk mengelakkan seorang pelawat membebankannya, pelayan mengira permintaan bagi setiap alamat internet, dalam memori sahaja. Alamat itu tidak pernah ditulis ke cakera.';

  @override
  String get privacyPicturesTitle =>
      'Gambar datang daripada pelayan imej Nintendo';

  @override
  String get privacyPicturesBody =>
      'Seni permainan dan tangkapan skrin dimuatkan terus daripada pelayan imej kedai (img-eshop.cdn.nintendo.net). Pelayar atau telefon anda meminta setiap gambar daripada pelayan itu, jadi Nintendo menerima alamat internet anda dan butiran biasa sesuatu permintaan, di bawah dasar privasi Nintendo sendiri. Ringgit Radar tidak menyimpan sebarang gambar dan tidak menyerahkannya kepada pihak lain.';

  @override
  String get privacyOthersTitle => 'Siapa lagi yang melihat lawatan anda';

  @override
  String get privacyOthersBody =>
      'Laman dan pelayannya berjalan di Vercel. Vercel menyimpan log permintaan di bawah dasarnya sendiri, yang boleh termasuk halaman yang anda minta, masa, alamat internet anda dan jenis pelayar anda. Data harga disimpan di Supabase; ia hanya menyimpan harga permainan dan tiada apa-apa tentang pelawat, dan ia hanya menerima permintaan daripada pelayan kami. Selain gambar tersebut, versi web memuatkan segala-galanya, termasuk fon, daripada alamat kami sendiri, dan aplikasi Android hanya berhubung dengan pelayan kami.';

  @override
  String get privacyNotNintendoTitle => 'Bukan Nintendo';

  @override
  String get privacyNotNintendoBody =>
      'Ringgit Radar ialah aplikasi bebas yang tidak rasmi. Ia tiada hubungan dengan Nintendo dan tidak diiktiraf oleh Nintendo. Harga dikumpul daripada Nintendo eShop Malaysia dan ditunjukkan bersama sejarahnya; untuk membeli permainan, gunakan Switch anda.';

  @override
  String get privacyEnglishPrevails =>
      'Halaman ini ialah terjemahan versi bahasa Inggeris; jika terdapat perbezaan, versi bahasa Inggeris terpakai.';

  @override
  String get backToAbout => 'Kembali ke Perihal';

  @override
  String get onSaleChip => 'Promosi';

  @override
  String get noneOnSale =>
      'Tiada permainan dalam Senarai Hajat anda yang dalam promosi sekarang.';

  @override
  String get wishEmptyTitle =>
      'Anda boleh menambah perisian yang anda minati ke Senarai Hajat anda!';

  @override
  String get wishEmptyHint =>
      'Ketik ikon hati pada mana-mana permainan, dalam senarai atau pada halamannya, untuk menambahnya di sini.';

  @override
  String get genreAction => 'Aksi';

  @override
  String get genreAdventure => 'Pengembaraan';

  @override
  String get genrePuzzle => 'Teka-teki';

  @override
  String get genreSimulation => 'Simulasi';

  @override
  String get genreArcade => 'Arked';

  @override
  String get genreRpg => 'RPG';

  @override
  String get genreStrategy => 'Strategi';

  @override
  String get genreOther => 'Lain-lain';

  @override
  String get genrePlatformer => 'Platformer';

  @override
  String get genreShooter => 'Tembak-menembak';

  @override
  String get genreParty => 'Parti';

  @override
  String get genreMultiplayer => 'Berbilang Pemain';

  @override
  String get genreRacing => 'Perlumbaan';

  @override
  String get genreSports => 'Sukan';

  @override
  String get genreBoardGame => 'Permainan Papan';

  @override
  String get genreFighting => 'Pertarungan';

  @override
  String get genreLifestyle => 'Gaya Hidup';

  @override
  String get genreCommunication => 'Komunikasi';

  @override
  String get genreEducation => 'Pendidikan';

  @override
  String get genreTraining => 'Latihan';

  @override
  String get genreStudy => 'Pembelajaran';

  @override
  String get genreUtility => 'Utiliti';

  @override
  String get genreFirstPersonShooter => 'Tembak-menembak FPS';

  @override
  String get genreMusic => 'Muzik';

  @override
  String get genrePractical => 'Praktikal';

  @override
  String get genreVideo => 'Video';

  @override
  String get noticeTitle => 'Aplikasi bebas';

  @override
  String get noticeBody =>
      'Ringgit Radar ialah aplikasi bebas yang tidak rasmi. Ia tiada hubungan dengan Nintendo dan tidak diiktiraf oleh Nintendo. Ia menyimpan rekodnya sendiri tentang harga eShop Malaysia; untuk membeli permainan, gunakan Switch anda.';

  @override
  String get noticeOk => 'OK';

  @override
  String get dataSourcesTitle => 'Dari mana data kami datang';

  @override
  String get unofficialLabel => 'Tidak rasmi';

  @override
  String get wordmarkSemantics => 'Ringgit Radar, tidak rasmi';

  @override
  String get descriptionSource => 'Daripada senarai kedai penerbit';
}
