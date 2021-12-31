import '../objectbox.g.dart';

late Store store;

Future<Store> initStore() async {
  store = await openStore(macosApplicationGroup: "世华刘.link-note");
  return store;
}
