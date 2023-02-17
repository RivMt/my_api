import 'package:decimal/decimal.dart';
import 'package:my_api/core/api/api_core.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/finance/model/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {

  /// Client
  final ApiCore _client = ApiCore();

  /// Init
  ///
  /// Initiate server connection. If login is required, [onLoginRequired]
  /// will be triggered.
  ///
  /// [preferences] are `json` data of server addresses.
  ///
  /// You can select `Production` and `Test` server using [useTest]. If it
  /// is `null`, server will be selected by [kDebugMode]. Otherwise, follow its
  /// value.
  ///
  /// The structure of `json` file like below.
  /// ```json
  /// {
  ///   "url": PRODUCTION-SERVER-ADDRESS,
  ///   "test": TEST-SERVER-ADDRESS
  /// }
  /// ```
  Future<void> init({
    required Function() onLoginRequired,
    required Map<String, dynamic> preferences,
    bool? useTest,
  }) async {
    // Check json file
    if (!preferences.containsKey("url") || !preferences.containsKey("test")) {
      throw const FileSystemException("Key 'url' or 'test' does not exists.");
    }
    // Load url from json
    final bool setup = useTest ?? kDebugMode;
    final String url = setup ? preferences["test"]! : preferences["url"]!;
    _serverType = setup ? ServerType.test : ServerType.production;
    // Init
    _client.init(
      onLoginRequired: onLoginRequired,
      url: url,
    );
  }

  /// Send request
  Future<ApiResponse<Map<String, dynamic>>> send(
    ApiMethod method,
    String home,
    String path,
    List<Map<String, dynamic>> data, [
    Map<String, dynamic>? options,
    Map<String, dynamic>? queries,
  ]) async {
    final Map<String, dynamic> body = {
      "user_id": _client.id,
      "user_secret": _client.secret,
      "data": data,
    };
    if (options != null) {
      body['options'] = options;
    }
    String query = "";
    if (queries != null) {
      final q = [];
      for (String key in queries.keys) {
        q.add("$key=${queries[key]}");
      }
      query = "?${q.join("&")}";
    }
    final response = await _client.send(method, "$home/$path$query", body);
    return response;
  }

  /// Build options
  Map<String, dynamic> buildOptions({
    // Calculation
    CalculationType? calcType,
    String? calcAttribute,
    // Sort Order
    SortOrderType? sortOrderType,
    String? sortOrderAttribute,
    // Limit
    int? limit,
  }) {
    final Map<String, dynamic> map = {};
    // Calc
    if (calcType != null && calcAttribute != null) {
      map["calc"] = {
        "type": calcType.name.toUpperCase(),
        "attr": calcAttribute,
      };
    }
    // Order
    if (sortOrderType != null && sortOrderAttribute != null) {
      map["order"] = {
        "type": sortOrderType.name.toUpperCase(),
        "attr": sortOrderAttribute,
      };
    }
    // Limits
    if (limit != null) {
      map["limit"] = limit;
    }
    return map;
  }

  /// Get home from [T]
  String home<T>() {
    switch(T) {
      case Account:
      case Payment:
      case Transaction:
      case Category:
        return "finance/v1";
      case Preference:
        return "userdata/v1";
      default:
        throw UnimplementedError();
    }
  }

  /// Get path from [T]
  String path<T>() {
    switch(T) {
      case Account:
        return "accounts";
      case Payment:
        return "payments";
      case Transaction:
        return "transactions";
      case Category:
        return "categories";
      case Preference:
        return "preferences";
      default:
        throw UnimplementedError();
    }
  }

  /// Covert [map] to [T]
  dynamic convert<T>(Map<String, dynamic> map, [String key = "data"]) {
    final data = (key == "") ? map : map[key];
    switch(T) {
      case Decimal:
        if (data is! String) {
          return Decimal.zero;
        }
        return Decimal.parse(data);
      case Account:
        return Account(data);
      case Payment:
        return Payment(data);
      case Transaction:
        return Transaction(data);
      case Category:
        return Category(data);
      case Preference:
        return Preference(data);
      default:
        throw UnimplementedError();
    }
  }

  /// Covert multiple items in [map] to [T]
  List<T> converts<T>(Map<String, dynamic> map, [String key = "data"]) {
    final List<T> list = [];
    final data = (key == "") ? map : (map[key] ?? []);
    for (Map<String, dynamic> m in data) {
      list.add(convert<T>(m, ""));
    }
    return list;
  }

  /// Create [data] from [link]
  Future<ApiResponse<List<T>>> create<T>(List<Map<String, dynamic>> data) async {
    final result = await send(ApiMethod.put, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>(List<Map<String, dynamic>> data, [Map<String, dynamic>? options]) async {
    final result = await send(ApiMethod.post, home<T>(), path<T>(), data, options);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Update [data] from [link]
  Future<ApiResponse<List<T>>> update<T>(List<Map<String, dynamic>> data) async {
    final result = await send(ApiMethod.patch, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Delete [data] from [link]
  Future<ApiResponse<List<T>>> delete<T>(List<Map<String, dynamic>> data) async {
    final result = await send(ApiMethod.delete, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Request calculation result which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attribute] defines column name
  /// which is calculated
  Future<ApiResponse<Decimal>> calculate<T>(
    List<Map<String, dynamic>> data,
    CalculationType calc,
    String attribute, [
      Map<String, dynamic>? queries,
  ]) async {
    final result = await send(
      ApiMethod.post,
      home<T>(),
      path<T>(),
      data,
      buildOptions(
        calcType: calc,
        calcAttribute: attribute,
      ),
      queries,
    );
    return result.convert<Decimal>(convert<Decimal>(result.data));
  }

  /// Get preference value from [key]
  ///
  /// If [SharedPreference] does not have value about [key], it requests
  /// API server to get value and save to local. And that request also failed,
  /// return [Preference] instance that has [defaultValue].
  Future<Preference> getPreference(String key, dynamic defaultValue) async {
    // Check local preference has value
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString(key);
    if (local != null) {
      Log.i("GetPref", "Get preference $key=$local from local strorage");
      return Preference.fromKV({},
        key: key,
        value: local,
      );
    }
    // If not exists, send request to API server
    final response = await read<Preference>([{
      Preference.keyKey: key,
    }]);
    if (response.result == ApiResultCode.success && response.data.length == 1) {
      final value = response.data[0];
      // Save to local
      Log.i("GetPref", "Get preference $key=${value.rawValue} from API server");
      prefs.setString(key, value.rawValue);
      return value;
    }
    // Otherwise, return default
    Log.w("GetPref", "Unable to find $key from anywhere");
    return Preference.fromKV({},
      key: key,
      value: defaultValue,
    );
  }

  /// Set [value] about [key]
  ///
  /// It request to save [pref] to server. If it failed, don't save to local
  /// storage. It only save [pref] to local storage when request succeed.
  ///
  /// This process is required to idealize local and server.
  Future<ApiResponse<Preference>> setPreference(Preference pref) async {
    // Save in server first
    final response = await create<Preference>([pref.map]);
    if (response.result != ApiResultCode.success || response.data.length != 1) {
      // If failed, return failed response
      return response.convert(Preference.unknown);
    }
    // Save local
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(pref.key, pref.rawValue);
    //
    return response.convert(response.data[0]);
  }
}