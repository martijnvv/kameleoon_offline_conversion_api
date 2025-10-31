___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.

___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Kameleoon Offline Conversion API",
  "categories": "[EXPERIMENTATION]",
  "brand": {
    "id": "martijnvv",
    "displayName": "martijnvv"
  },
  "description": "The Offline Conversion API, leveraged to send goal conversions to Kameleoon via GTM Serverside",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "region",
    "displayName": "Kameleoon Region / Domain",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "auto",
        "displayValue": "Auto (data.kameleoon.io)"
      },
      {
        "value": "eu",
        "displayValue": "EU (eu-data.kameleoon.io)"
      },
      {
        "value": "na",
        "displayValue": "North America (na-data.kameleoon.io)"
      },
      {
        "value": "custom",
        "displayValue": "Custom domain"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "auto"
  },
  {
    "type": "TEXT",
    "name": "customDomain",
    "displayName": "Custom domain (optional)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "region",
        "paramValue": "custom",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "siteCode",
    "displayName": "Kameleoon siteCode",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "goalId",
    "displayName": "goalId",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NUMBER"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "revenue",
    "displayName": "revenue (optional)",
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "negative",
    "checkboxText": "Mark as negative conversion (remove)",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "revenue",
        "paramValue": "",
        "type": "PRESENT"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "timeoutMs",
    "displayName": "Timeout (ms)",
    "simpleValueType": true,
    "defaultValue": 4000
  },
  {
    "type": "CHECKBOX",
    "name": "debug",
    "checkboxText": "Debug logging",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

// https://developers.kameleoon.com/apis/data-api-rest/tutorials/processing-offline-goal-conversions-in-experiments/#sending-offline-goal-conversion
const sendHttpRequest = require('sendHttpRequest');
const logToConsole = require('logToConsole');
const setResponseBody = require('setResponseBody');
const setResponseStatus = require('setResponseStatus');
const setResponseHeader = require('setResponseHeader');
const JSON = require('JSON');
const makeString = require('makeString');
const makeNumber = require('makeNumber');
const encodeUriComponent = require('encodeUriComponent');
const getCookieValues = require('getCookieValues');
const generateRandom = require('generateRandom');
const getAllEventData = require('getAllEventData');
const eventData = getAllEventData();
const user_agent = eventData.user_agent;
const cookie_value = getCookieValues('kameleoonVisitorCode')[0];

function isFiniteNumber(n) {
  return typeof n === 'number' && n === n;
}

function makeNonce() {
  var chars = 'abcdef0123456789';
  var out = '';
  for (var i = 0; i < 16; i++) {
    var r = generateRandom(0, chars.length - 1); 
    out += chars.charAt(r);
  }
  return out;
}

function chooseHost(region, customDomain) {
  if (region === 'eu') return 'https://eu-data.kameleoon.io';
  if (region === 'na') return 'https://na-data.kameleoon.io';
  if (region === 'custom' && customDomain) {
    var cd = '' + customDomain;
    if (!(cd.indexOf('http://') === 0 || cd.indexOf('https://') === 0)) {
      cd = 'https://' + cd;
    }
    if (cd.lastIndexOf('/') === cd.length - 1) {
      cd = cd.slice(0, -1);
    }
    return cd;
  }
  return 'https://data.kameleoon.io';
}

function parseOptionalJson(str) {
  if (!str) return undefined;
  var s = '' + str;
  if (!(s.charAt(0) === '{' && s.charAt(s.length - 1) === '}')) return undefined;
  return JSON.parse(s);
}

var region       = data.region || 'auto';
var customDomain = data.customDomain || '';
var siteCode     = data.siteCode;
var visitorCode  = cookie_value || undefined;
var goalIdNum    = makeNumber(data.goalId);
var revenueNum   = makeNumber(data.revenue);
var negative     = !!data.negative;
var metadata     = parseOptionalJson(data.metadata);
var timeoutMs    = makeNumber(data.timeoutMs);
if (!isFiniteNumber(timeoutMs)) timeoutMs = 4000;
var debug        = !!data.debug;

function failEarly(msg) {
  setResponseStatus(400);
  setResponseHeader('x-kameleoon-error', 'validation');
  setResponseBody('' + msg);
  if (debug) logToConsole('Kameleoon Offline Goal validation error', msg);
  data.gtmOnFailure();
}

if (!siteCode) { failEarly('Missing siteCode'); return; }
if (!visitorCode) { failEarly('Missing visitorCode'); return; }
if (!isFiniteNumber(goalIdNum)) { failEarly('Missing or invalid goalId'); return; }

// ---- Build request ----
var host = chooseHost(region, customDomain);
var siteCodeStr = makeString(siteCode);
var visitorCodeStr = makeString(visitorCode);

// Force JSON mode per GTM SSG + Kameleoon docs
var endpoint = host + '/visit/events'
  + '?json=true'
  + '&siteCode=' + encodeUriComponent(siteCodeStr)
  + '&visitorCode=' + encodeUriComponent(visitorCodeStr);

var event = {
  nonce: makeNonce(),
  eventType: 'CONVERSION',
  goalId: goalIdNum
};
if (isFiniteNumber(revenueNum)) event.revenue = revenueNum;
if (negative) event.negative = true;
if (metadata && typeof metadata === 'object') event.metadata = metadata;

var headers = { 'Content-Type': 'application/json' };
headers['User-Agent'] = user_agent;

var body = JSON.stringify([event]);
logToConsole(body);
if (debug) logToConsole('Kameleoon Offline Goal request', { url: endpoint, headers: headers, body: body });

// ---- Send ----
sendHttpRequest(endpoint, {
  method: 'POST',
  headers: headers,
  timeout: timeoutMs,
  body: body
}).then(function(resp) {
  var status = resp.statusCode || 0;
  setResponseStatus(status);
  setResponseHeader('x-kameleoon-status', '' + status);
  setResponseBody(resp.body || '');
  if (debug) logToConsole('Kameleoon Offline Goal response', resp);

  if (status >= 200 && status < 300) {
    data.gtmOnSuccess();
  } else {
    data.gtmOnFailure();
  }
}).catch(function(err) {
  setResponseStatus(500);
  setResponseHeader('x-kameleoon-error', 'request');
  setResponseBody('' + ((err && err.message) || err));
  if (debug) logToConsole('Kameleoon Offline Goal error', err);
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://data.kameleoon.io/*"
              },
              {
                "type": 1,
                "string": "https://eu-data.kameleoon.io/*"
              },
              {
                "type": 1,
                "string": "https://na-data.kameleoon.io/*"
              },
              {
                "type": 1,
                "string": "https://*.yourcustomdomain.com/*"
              }
            ]
          }
        },
        {
          "key": "allowGoogleDomains",
          "value": {
            "type": 8,
            "boolean": true
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "kameleoonVisitorCode"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 10/31/2025, 9:46:32 AM


