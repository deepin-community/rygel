public class PlaySpeed : Object {
    public double speed = 1.0;

    public bool is_positive () { return this.speed >= 0; }
    public bool is_normal_rate () { return this.speed == 1.0; }
}

public class HTTPGetHandler : Object {
    public int64 get_resource_duration () {
        return 0;
    }

    public bool supports_time_seek () { return true; }
}

public class ClientHacks : Object {
    public static ClientHacks? create (Soup.Message message) throws Error {
        throw new NumberParserError.INVALID ("");
    }

    public bool force_seek () { return false; }
}

void test_time_seek_malformed_header () {
    // Mock data
    var message = new Soup.Message ("GET", "http://localhost");
    var handler = new HTTPGetHandler ();

    // Test without the header
    try {
        new Rygel.HTTPTimeSeekRequest (message, handler, null);
        assert_not_reached ();
    } catch (Error e) {
        // Pass - we only expect a HTTPSeekRequestError
        assert (e is Rygel.HTTPSeekRequestError.INVALID_RANGE);
    }

    // Test empty header
    message.request_headers.replace (Rygel.HTTPTimeSeekRequest.TIMESEEKRANGE_HEADER, "");
    try {
        new Rygel.HTTPTimeSeekRequest (message, handler, null);
        assert_not_reached ();
    } catch (Error e) {
        // Pass - we only expect a HTTPSeekRequestError
        assert (e is Rygel.HTTPSeekRequestError.INVALID_RANGE);
    }

    // Test empty header
    message.request_headers.replace (Rygel.HTTPTimeSeekRequest.TIMESEEKRANGE_HEADER, "npt=kjalsjd lsdjldskj lkfdsj ");
    try {
        new Rygel.HTTPTimeSeekRequest (message, handler, null);
        assert_not_reached ();
    } catch (Error e) {
        // Pass - we only expect a HTTPSeekRequestError
        assert (e is Rygel.HTTPSeekRequestError.INVALID_RANGE);
    }

    // Must not have white-spaces before npt=
    message.request_headers.replace (Rygel.HTTPTimeSeekRequest.TIMESEEKRANGE_HEADER,
                                     "         npt=0.000-");
    try {
        new Rygel.HTTPTimeSeekRequest (message, handler, null);
        assert_not_reached ();
    } catch (Error e) {
        // Pass - we only expect a HTTPSeekRequestError
        assert (e is Rygel.HTTPSeekRequestError.INVALID_RANGE);
    }

    // Must not have white-spaces in the time
    message.request_headers.replace (Rygel.HTTPTimeSeekRequest.TIMESEEKRANGE_HEADER,
                                     "npt = 00 : 05 : 35.3-00");
    try {
        new Rygel.HTTPTimeSeekRequest (message, handler, null);
        assert_not_reached ();
    } catch (Error e) {
        // Pass - we only expect a HTTPSeekRequestError
        assert (e is Rygel.HTTPSeekRequestError.INVALID_RANGE);
    }
}

int main(string[] args) {
    Intl.setlocale (LocaleCategory.ALL, "C");
    Test.init (ref args);

    Test.add_func ("/server/time-seek/request", test_time_seek_malformed_header);
    return Test.run ();
}
