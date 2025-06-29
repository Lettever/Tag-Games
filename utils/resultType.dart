/*abstract class Result<T, E> {
    const Result();
    bool get isOk => this is Ok<T, E>;
    bool get isErr => this is Err<T, E>;
    T? get ok => this is Ok<T, E> ? (this as Ok<T, E>).value : null;
    E? get err => this is Err<T, E> ? (this as Err<T, E>).error : null;
}

class Ok<T, E> extends Result<T, E> {
    final T value;
    const Ok(this.value);
}
class Err<T, E> extends Result<T, E> {
    final E error;
    const Err(this.error);
}*/

sealed class Result<T, E> {
    const Result();

    bool isOk() => this is Ok<T, E>;
    bool isErr() => this is Err<T, E>;

    T get value {
        if (isOk()) return (this as Ok<T, E>).value;
        throw StateError('Tried to access value of Err: ${(this as Err<T, E>).error}');
    }

    E get error {
        if (this is Err<T, E>) return (this as Err<T, E>).error;
        throw StateError('Tried to access error of Ok: ${(this as Ok<T, E>).value}');
    }

    factory Result.ok(T value) = Ok<T, E>;
    factory Result.err(E error) = Err<T, E>;
}

final class Ok<T, E> extends Result<T, E> {
    final T value;
    const Ok(this.value);
}

final class Err<T, E> extends Result<T, E> {
    final E error;
    const Err(this.error);
}
void main() {}