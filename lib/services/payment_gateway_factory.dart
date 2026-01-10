import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/services/payment_gateway.dart';
import 'package:bus_ticketing_app/services/stripe_gateway.dart';
import 'package:bus_ticketing_app/services/phonepe_gateway.dart';
import 'package:bus_ticketing_app/services/gpay_gateway.dart';
import 'package:bus_ticketing_app/services/paytm_gateway.dart';
import 'package:bus_ticketing_app/services/upi_qr_gateway.dart';
import 'package:bus_ticketing_app/services/net_banking_gateway.dart';
import 'package:bus_ticketing_app/services/razorpay_gateway.dart';

abstract class PaymentGatewayFactory {
  PaymentGateway createGateway(BuildContext context);
}

class StripeGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return StripeGateway(context);
  }
}

class PhonePeGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return PhonePeGateway();
  }
}

class GPayGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return GPayGateway();
  }
}

class PaytmGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return PaytmGateway();
  }
}

class UpiQrGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return UpiQrGateway();
  }
}

class NetBankingGatewayFactory implements PaymentGatewayFactory {
  @override
  PaymentGateway createGateway(BuildContext context) {
    return NetBankingGateway();
  }
}

class RazorpayGatewayFactory implements PaymentGatewayFactory {
  final Function(String)? onSuccess;
  final Function(String)? onError;

  RazorpayGatewayFactory({this.onSuccess, this.onError});

  @override
  PaymentGateway createGateway(BuildContext context) {
    return RazorpayGateway(context, onSuccess: onSuccess, onError: onError);
  }
}
