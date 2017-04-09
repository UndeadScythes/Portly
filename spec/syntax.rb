def s(r) r.source end

# RFC 1945 2.2
OCTET        = /[\x00-\xFF]/
CHAR         = /[\x00-\x7F]/
UPALPHA      = /[A-Z]/
LOALPHA      = /[a-z]/
ALPHA        = /[a-zA-Z]/
DIGIT        = /\d/
CTL          = /[\x00-\x1F\x7F]/
CR           = /\n/
LF           = /\r/
SP           = / /
HT           = /\t/
DOUBLE_QUOTE = /"/

CRLF = /#{s(CR)}#{s(LF)}/
LWS  = /(?:#{s(CRLF)})?[#{s(SP)}#{s(HT)}]+/
TEXT = /#{s(LWS)}|(?!#{s(CTL)})#{s(OCTET)}/
HEX  = /[\dA-Fa-f]/

tspecials = /[()<>@,;:\\#{s(DOUBLE_QUOTE)}\/[\]?={}#{s(SP)}#{s(HT)}]/
token     = /(?:(?!#{s(CTL)}|#{s(tspecials)})#{s(CHAR)})+/

ctext   = /(?![()])#{s(TEXT)}/
comment = /\((?:#{s(ctext)}|\((?:#{s(ctext)})*\))*\)/

qdtext        = /(?:#{s(LWS)}|(?!#{s(DOUBLE_QUOTE)}|#{s(CTL)})#{s(CHAR)})/
quoted-string = /#{s(DOUBLE_QUOTE)}#{s(qdtext)}*#{s(DOUBLE_QUOTE)}/

word = /#{s(token)}|#{s(quoted-string)}/

# RFC 1945 3.1
HTTP-Version = /HTTP\/#{s(DIGIT)}+\.#{s(DIGIT)}+/

# RFC 1945 3.2.1
escape   = /%#{s(HEX)}{2}/
reserved = /[;\/?:@&=+]/
extra    = /[!*'(),]/
safe     = /[$_.-]/
unsafe   = /[#{s(CTL)}#{s(SP)}#{s(DOUBLE_QUOTE)}#%<>]/
national = /(?!#{s(ALPHA)}|#{s(DIGIT)}|#{s(reserved)}|#{s(extra)}|#{s(safe)}|#{s(unsafe)})#{s(OCTET)}/

unreserved = /#{s(ALPHA)}|#{s(DIGIT)}|#{s(safe)}|#{s(extra)}|#{s(national)}/
uchar      = /#{s(unreserved)}|#{s(escape)}/
pchar      = /#{s(uchar)}|[:@&=+]/

fragment = /(?:#{s(uchar)}|#{s(reserved)})*/
query    = /(?:#{s(uchar)}|#{s(reserved)})*/
net_loc  = /(?:#{s(pchar)}|[;?])*/
scheme   = /(?:#{s(ALPHA)}|#{s(DIGIT)}|[+.-])+/

param  = /(?:#{s(pchar)}|\/)*/
params = /#{s(param)}(?:;#{s(param)})*/

segment  = /(?:#{s(pchar)})*/
fsegment = /(?:#{s(pchar)})+/
path     = /#{s(fsegment)}(?:\/#{s(segment)})*/

rel_path = /(?:#{s(path)})?(?:;#{s(params)})?(?:\?#{s(query)})?/
abs_path = /\/#{s(rel_path)}/
net_path = /\/\/#{s(net_loc)}(?:#{s(abs_path)})?/

relativeURI = /#{s(net_path)}|#{s(abs_path)}|#{s(rel_path)}/

absoluteURI = /#{s(scheme)}:(?:#{s(uchar)}|#{s(reserved)})*/

URI = /(?:#{s(absoluteURI)}|#{s(relativeURI)})(?:\##{s(fragment)})?/

# RFC 1945 3.2.2
host     = /(?:[A-Z0-9](?:[A-Z0-9.-]{0,23}[A-Z0-9])?|\d+\.\d+\.\d+\.\d+)/
port     = /#{s(DIGIT)}*/
http_URL = /http:\/\/#{s(host)}(?:#{s(port)})?(?:#{s(abs_path)})?/

# RFC 1945 3.3
time    = /#{s(DIGIT)}{2}:#{s(DIGIT)}{2}:#{s(DIGIT)}{2}/
wkday   = /Mon|Tue|Wed|Thu|Fri|Sat|Sun/
weekday = /Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday/
month   = /Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec/

date1   = /#{s(DIGIT)}{2}#{s(SP)}#{s(month)}#{s(SP)}#{s(DIGIT)}{4}/
date2   = /#{s(DIGIT)}{2}-#{s(month)}-#{s(DIGIT)}{2}/
date3   = /#{s(month)}#{s(SP)}(?:#{s(DIGIT)}{2}|#{s(SP)}#{s(DIGIT)})/

rfc1123-date = /#{s(wkday)},#{s(SP)}#{s(date1)}#{s(SP)}#{s(time)}#{s(SP)}GMT/
rfc850-date  = /#{s(weekday)},#{s(SP)}#{s(date2)}#{s(SP)}#{s(time)}#{s(SP)}GMT/
asctime-date = /#{s(wkday)}#{s(SP)}#{s(date3)}#{s(SP)}#{s(time)}#{s(SP)}#{s(DIGIT)}{4}/

HTTP-date = /#{s(rfc1123-date)}|#{s(rfc850-date)}|#{s(asctime-date)}/

# RFC 1945 3.4
charset = /US-ASCII|ISO-8859-1|ISO-8859-2|ISO-8859-3|ISO-8859-4|ISO-8859-5|ISO-8859-6|ISO-8859-7|ISO-8859-8|ISO-8859-9|ISO-2022-JP|ISO-2022-JP-2|ISO-2022-KR|UNICODE-1-1|UNICODE-1-1-UTF-7|UNICODE-1-1-UTF-8|#{s(token)}/

# RFC 1945 3.5
content-coding = /x-gzip|x-compress|#{s(token)}/

# RFC 1945 3.6
attribute = /#{s(token)}/
value     = /#{s(token)}|#{s(quoted-string)}/
parameter = /#{s(attribute)}=#{s(value)}/

type       = /#{s(token)}/
subtype    = /#{s(token)}/
media-type = /#{s(type)}\/#{s(subtype)}(?:;#{s(parameter)})*/

# RFC 1945 3.7
product-version = /#{s(token)}/
product         = /#{s(token)}(?:\/#{s(product-version)})?/

# RFC 1945 4.1
Request-Line = //
General-Header = //
Request-Header = //
Entity-Header = //
Entity-Body = //

Full-Request  = /#{s(Request-Line)}(?:#{s(General-Header)}|#{s(Request-Header)}|#{s(Entity-Header)})*#{s(CRLF)}(?:#{s(Entity-Body)})?/

Status-Line = //
Response-Header = //

Full-Response = /#{s(Status-Line)}(?:#{s(General-Header)}|#{s(Response-Header)}|#{s(Entity-Header)})#{s(CRLF)}(?:#{s(Entity-Body)})?/

Request-URI = //

Simple-Request = /GET#{s(SP)}#{s(Request-URI)}#{s(CRLF)}/

Simple-Response = /(?:#{s(Entity-Body)})?/

HTTP-message = /#{s(Simple-Request)}|#{s(Simple-Response)}|#{s(Full-Request)}|#{s(Full-Response)}/