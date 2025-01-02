## 0.2.0

* BREAKING: Removed `extends Object` constraint from `TurboResponseX` extension to allow for more flexible type handling
* Fixed issue with `isSuccess` getter not being accessible for `TurboResponse<void>`

## 0.1.0+1

* Updated repository URLs to point to the correct GitHub repository
* Fixed formatting issues in turbo_response.dart

## 0.1.0

* Initial release
* Added `TurboResponse` sealed class with `Success` and `Fail` variants
* Added pattern matching support with `when` and `maybeWhen`
* Added convenience methods `whenSuccess` and `whenFail` for single-state handling
* Added functional transformations with `fold`, `mapSuccess`, and `mapFail`
* Added value extraction with `unwrap`, `unwrapOr`, and `unwrapOrCompute`
* Added error recovery with `recover` and `andThen`
* Added property getters for `result`, `title`, `message`, and `error`
* Added `throwFail` method for Firestore transaction support
* Added comprehensive test coverage
* Added improved debugging support with custom `toString` implementation
* Made `result` getter non-nullable and throw `TurboException` in fail state
* Made `error` optional in `TurboException` with `hasError`, `hasTitle`, and `hasMessage` getters
