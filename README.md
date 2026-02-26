# Kameleoon – Server-Side Offline Conversion API (GTMSS Template)

> ⚠️ **Experimental / Unofficial Template**
>
> This custom Google Tag Manager Server-Side template is unofficial and not maintained by Kameleoon.  

---

## Overview

This repository contains a **custom Google Tag Manager Server-Side (GTMSS) tag template** for sending offline and server-side conversion events to **Kameleoon** via its Offline Conversion API.

The template enables you to:

- Send backend-validated conversion events
- Attribute purchases to experiments server-side
- Reduce client-side dependency
- Improve tracking reliability
- Enforce stricter data governance

This implementation is especially useful for:

- Server-validated purchases
- CRM-synced conversions
- Delayed conversion events
- Subscription renewals
- Backend-only transactions

---

## What This Template Does

The template:

- Receives event data inside GTM Server-Side
- Formats the payload according to Kameleoon’s Offline Conversion API
- Sends authenticated HTTP requests to Kameleoon’s endpoint
- Supports experiment attribution via visitor identifiers
- Allows revenue and goal value forwarding
- Enables environment-specific configuration

The template does **not** trigger experiments.  
It strictly sends conversion data to Kameleoon.

---

## Architecture

Typical setup:

Browser → Web GTM → Server-Side GTM → Kameleoon API  
Backend / CRM → Server-Side GTM → Kameleoon API

### Flow

1. A conversion event occurs (purchase, subscription, lead, etc.).
2. The event is forwarded to GTM Server-Side.
3. The GTMSS Kameleoon tag formats the payload.
4. A server-to-server request is sent to Kameleoon.
5. Kameleoon attributes the conversion to experiments (if applicable).

---

## Prerequisites

Before installing:

- Kameleoon account
- Offline Conversion API enabled
- API credentials (Client ID / Secret or API Key)
- Site Code
- Server-Side GTM container deployed
- Secure first-party server domain configured
- Proper consent management in place

---

## Installation

1. Open your **GTM Server-Side container**
2. Navigate to:
   Templates → Tag Templates → New
3. Click:
   Import
4. Upload the file:
   `Kameleoon - Unofficial Offline Conversion API.tpl`
5. Save the template.

---

## Tag Configuration

After importing:

1. Create a new Tag
2. Select:
   `Kameleoon – Offline Conversion (Server-Side)`
3. Configure the following fields.

---

## Required Fields

- **Site Code**
- **API Endpoint**
- **Authentication credentials**
- **Visitor Identifier**
- **Goal ID or Conversion Identifier**

---

## Supported Event Types

The template supports forwarding structured conversion events to Kameleoon.

### Purchase / Revenue Conversion

Triggered when a transaction is completed server-side.

**Required parameters:**

- `visitor_id`
- `goal_id`
- `conversion_id` (recommended for deduplication)

**Recommended parameters:**

- `revenue`
- `currency`
- `transaction_id`
- Custom metadata

---

### Lead / Signup Conversion

Triggered when a user completes a lead or signup event.

**Required parameters:**

- `visitor_id`
- `goal_id`

**Recommended parameters:**

- Lead value
- Lead type
- Custom attributes

---

### Delayed / CRM Synced Conversion

Triggered when conversion happens after initial visit (e.g., offline sale, renewal).

**Required parameters:**

- `visitor_id`
- `goal_id`

**Recommended parameters:**

- Timestamp override
- Revenue
- Custom segmentation attributes

---

> ⚙️ **Implementation Note**
>
> The template does not define business logic.  
> It formats and forwards event payloads based on mapped GTM Server-Side variables.  
> Proper identifier consistency between frontend and backend is critical for accurate attribution.

---

## Visitor Identification

Accurate attribution depends on consistent visitor identifiers.

You must ensure that:

- The same `visitor_id` used in frontend Kameleoon experiments
- Is forwarded to GTM Server-Side
- And included in the Offline Conversion request

Failure to align identifiers will prevent experiment attribution.

---

## Authentication

Depending on your Kameleoon configuration, authentication may require:

- API Key
- OAuth token
- Client credentials
- Environment-specific headers

Always confirm authentication format with your Kameleoon Account Manager.

---

## Testing & Validation

1. Enable Preview Mode in GTM Server-Side.
2. Trigger a test conversion.
3. Verify:
   - Tag execution
   - Outgoing HTTP request
   - Response status code
4. Confirm conversion appears inside Kameleoon reporting.

If conversions do not appear:

- Validate API credentials
- Confirm correct Site Code
- Check visitor ID consistency
- Inspect server logs for errors

---

## Deployment

After validation:

1. Publish your GTM Server-Side container.
2. Monitor:
   - Conversion volumes
   - Error rates
   - Attribution consistency

---

## Security & Privacy Notes

- Ensure consent compliance before sending conversion data
- Avoid sending PII unless explicitly allowed
- Use secure HTTPS endpoints
- Store credentials securely in GTMSS template fields

---

## Versioning

Recommended:

- Use Git for version control
- Maintain a `CHANGELOG.md`
- Test changes in staging before production

---

## Support

This template is unofficial and not supported by Kameleoon.

For:

- API activation
- Goal configuration
- Attribution troubleshooting
- Environment setup

Contact your Kameleoon Account Manager.

---

## Disclaimer

This template is provided as-is, without warranty.  
Always validate against Kameleoon’s official API documentation before deploying to production.
