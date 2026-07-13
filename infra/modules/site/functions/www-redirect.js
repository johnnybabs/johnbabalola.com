function handler(event) {
    var request = event.request;
    var host = request.headers.host.value;

    // Redirect www.<domain> to the apex, preserving path and query string.
    if (host.startsWith('www.')) {
        var apex = host.slice(4);
        var qs = request.querystring
            ? '?' + Object.keys(request.querystring).map(function (k) {
                return k + '=' + request.querystring[k].value;
            }).join('&')
            : '';
        return {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': { value: 'https://' + apex + request.uri + qs }
            }
        };
    }

    return request;
}
