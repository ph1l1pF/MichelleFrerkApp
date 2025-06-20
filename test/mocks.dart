import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:michelle_frerk/services/checkout_service.dart';

@GenerateMocks([CheckoutService, http.Client])
void main() {}
