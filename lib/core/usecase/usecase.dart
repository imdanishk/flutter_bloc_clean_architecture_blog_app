import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Every usecase is going to have one function because usecases are supposed to do just one
/// task - expose a high level functionality of whatever process of what you're doing, for example, sign up.
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
