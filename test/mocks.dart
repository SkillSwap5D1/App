import 'package:mockito/annotations.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/providers/request_provider.dart';

@GenerateMocks([
  AuthProvider,
  ListingProvider,
  RequestProvider,
])
void main() {}