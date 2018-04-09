#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "hostcheck.h"

static int should_match(const char* cn, const char* hostname) {
    if ( Curl_cert_hostcheck(cn, hostname) == CURL_HOST_NOMATCH ) {
        fprintf(stderr, "    FAIL: expected hostname '%s' to match common name '%s'\n", hostname, cn);
        return 1;
    }
    return 0;
}

static int should_not_match(const char* cn, const char* hostname) {
    if ( Curl_cert_hostcheck(cn, hostname) == CURL_HOST_MATCH ) {
        fprintf(stderr, "    FAIL: expected hostname '%s' not to match common name '%s'\n", hostname, cn);
        return 1;
    }
    return 0;
}

int main (int argc, char *argv[]) {
    int ret = 0;
    fprintf(stderr, "Testing wildcard hostname validation...\n");

    // positive test cases
    ret += should_match("www.example.com", "www.example.com");
    ret += should_match("*.example.com", "www.example.com");
    ret += should_match("xxx*.example.com", "xxxwww.example.com");
    ret += should_match("f*.example.com", "foo.example.com");
    ret += should_match("192.168.0.0", "192.168.0.0");

    // negative test cases
    ret += should_not_match("xxx.example.com", "www.example.com");
    ret += should_not_match("*", "www.example.com");
    ret += should_not_match("*.*.com", "www.example.com");
    ret += should_not_match("*.example.com", "baa.foo.example.com");
    ret += should_not_match("f*.example.com", "baa.example.com");
    ret += should_not_match("*.com", "example.com");
    ret += should_not_match("*fail.com", "example.com");
    ret += should_not_match("*.example.", "www.example.");
    ret += should_not_match("*.example.", "www.example");
    ret += should_not_match("", "www");
    ret += should_not_match("*", "www");
    ret += should_not_match("*.168.0.0", "192.168.0.0");
    ret += should_not_match("www.example.com", "192.168.0.0");

    if ( ret == 0 ) {
        fprintf(stderr, "unit tests passed\n");
    } else {
        fprintf(stderr, "unit tets failed\n");
    }
    return ret;
}
