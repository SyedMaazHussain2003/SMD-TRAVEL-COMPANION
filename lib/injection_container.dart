import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'data/datasources/local_data_source.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/travel_repository_impl.dart';
import 'domain/repositories/travel_repository.dart';
import 'domain/usecases/get_favorite_places.dart';
import 'domain/usecases/get_places.dart';
import 'domain/usecases/get_weather.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'presentation/bloc/travel_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Travel
  // Bloc
  sl.registerFactory(
    () => TravelBloc(
      getPlaces: sl(),
      getWeather: sl(),
      getFavoritePlaces: sl(),
      toggleFavorite: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPlaces(sl()));
  sl.registerLazySingleton(() => GetWeather(sl()));
  sl.registerLazySingleton(() => GetFavoritePlaces(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  // Repository
  sl.registerLazySingleton<TravelRepository>(
    () => TravelRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.instance);
}
