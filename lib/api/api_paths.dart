class ApiPaths {
  static const String serverLink = 'http://62.72.0.65:8001';

  static const String checkExpired = '$serverLink/api/v1/auth/protect';

  static const String signUp = '$serverLink/api/v1/auth/signup';
  static const String getAreas = '$serverLink/api/v1/area';
  static const String getCities = '$serverLink/api/v1/city/area/';

  static const String sendOTPToEmail = '$serverLink/api/v1/auth/sendOTP';
  static const String checkOTP = '$serverLink/api/v1/auth/getOTP';

  static const String signIn = '$serverLink/api/v1/auth/login';

  static const String sendResetPasswordRequest = '$serverLink/api/v1/auth/forgotPassword';

  static const String saveNewPassword = '$serverLink/api/v1/auth/forgotPassword';

  static const String getCategories = '$serverLink/api/v1/categories';
  static const String getSupCategories = '$serverLink/api/v1/subCategories/category/';

  static const String getShape = '$serverLink/api/v1/shapes';
  static const String getCarCategories = '$serverLink/api/v1/carBrands';
  static const String getCarModel = '$serverLink/api/v1/models';
  static const String getBrand = '$serverLink/api/v1/carSubBrands/carBrand/';

  static const String createAuction = '$serverLink/api/v1/mazad/';

  static const String getAuction = '$serverLink/api/v1/mazad/home?isCar=';
  static const String getAuctionImages = '$serverLink/api/v1/mazad/photos/';
  static const String getAuctionProfileImage = '$serverLink/api/v1/mazad/profile/';

  static const String searchAuction = '$serverLink/api/v1/mazad/search';

  static const String verifyPayment = '$serverLink/api/v1/wallet/';
  static const String getWalletAmount = '$serverLink/api/v1/wallet/';

  static const String getFavoriteAuction = '$serverLink/api/v1/favourite/';
  static const String addOrRemoveFavoriteAuction = '$serverLink/api/v1/favourite';

  static const String getComingSoonAuction = '$serverLink/api/v1/mazad/coomingSoon?page=';

  static const String getExpiredAuctionCreatedByMy = '$serverLink/api/v1/mazad/expired?user=';
  static const String getExpiredAuctionWonByMy = '$serverLink/api/v1/mazad/expired?winner=';
  static const String getExpiredAuctionAttendedByMy = '$serverLink/api/v1/mazad/joined/';

  static const String getAuctionAttendedByMy = '$serverLink/api/v1/mazad/joined/';
  static const String getAuctionCreatedByMy = '$serverLink/api/v1/mazad/created?user=';

  static const String addOffer = '$serverLink/api/v1/mazad/offer';

  static const String updateProfile = '$serverLink/api/v1/auth/update';

  static const String getPoints = '$serverLink/api/v1/point/';

  static const String getPrivacy = '$serverLink/api/v1/crontrol/privacy';

  static const String sendProblemToSupport = '$serverLink/api/v1/support?user=';
  static const String getSupportAnswers = '$serverLink/api/v1/support?user=';
}
