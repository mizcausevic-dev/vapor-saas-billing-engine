import Foundation

func htmlEscaped(_ value: String) -> String {
    value
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
}

func formatMoney(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = amount == floor(amount) ? 0 : 2
    return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
}

func pageShell(title: String, lane: String, current: String, summary: BillingSummary, body: String) -> String {
    func nav(_ href: String, _ label: String) -> String {
        let active = current == href ? "active" : ""
        return #"<a class="\#(active)" href="\#(href)">\#(label)</a>"#
    }

    return """
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>\(htmlEscaped(title))</title>
      <style>
        :root{
          --bg:#07111c;--panel:#142235;--line:rgba(101,140,198,.24);--text:#eef4ff;--muted:#a1b7d7;--accent:#82c8ff;--gold:#f2e2c0;--warn:#ffd58f;--danger:#ff9d95;--good:#8ce1b8;
        }
        *{box-sizing:border-box}
        body{margin:0;font-family:Inter,Segoe UI,sans-serif;color:var(--text);background:radial-gradient(circle at top left, rgba(70,110,180,.24), transparent 28%),linear-gradient(180deg,#06101a,#091523)}
        main{width:min(1460px,calc(100% - 40px));margin:20px auto;padding:22px;border:1px solid var(--line);border-radius:30px;background:linear-gradient(180deg,rgba(11,18,30,.96),rgba(8,14,25,.98))}
        .topbar,.hero,.metric,.panel,.card,.codebox{border:1px solid var(--line);border-radius:28px;background:linear-gradient(180deg,rgba(20,32,50,.92),rgba(13,22,37,.96))}
        .topbar{display:flex;justify-content:space-between;align-items:center;gap:16px;padding:12px 14px;margin-bottom:18px}
        .brand{color:var(--accent);letter-spacing:.28em;text-transform:uppercase;font-size:12px;font-weight:700}
        .lane{color:var(--muted);letter-spacing:.16em;text-transform:uppercase;font-size:12px;margin-left:14px}
        .status,.nav,.tags{display:flex;gap:10px;flex-wrap:wrap}
        .chip,.nav a,.tag{padding:9px 13px;border-radius:999px;border:1px solid rgba(101,140,198,.2);background:rgba(20,34,53,.82);color:var(--text);text-decoration:none;font-size:13px;font-weight:600}
        .nav a.active{color:var(--accent);background:rgba(130,200,255,.12)}
        .hero{display:grid;grid-template-columns:1.45fr .95fr;gap:18px;padding:28px;margin-bottom:20px}
        .eyebrow{color:var(--accent);letter-spacing:.28em;text-transform:uppercase;font-size:12px;font-weight:700}
        h1,h2,h3{margin:12px 0 14px;font-family:Georgia,serif;color:var(--gold);letter-spacing:-.05em}
        h1{font-size:68px;line-height:.92} h2{font-size:44px;line-height:1.02} h3{font-size:30px;line-height:1.04}
        p,li{color:var(--muted);line-height:1.55}
        .lede{font-size:22px;max-width:880px}
        .metrics,.grid-2,.grid-3,.grid-4{display:grid;gap:18px}
        .metrics{grid-template-columns:repeat(4,1fr);margin-bottom:20px}
        .grid-2{grid-template-columns:1.06fr .94fr}
        .grid-3{grid-template-columns:repeat(3,1fr)}
        .grid-4{grid-template-columns:repeat(4,1fr)}
        .metric,.panel,.card,.codebox{padding:22px}
        .metric strong{display:block;margin:14px 0 10px;font-family:Georgia,serif;font-size:52px;line-height:.95;color:var(--gold)}
        .metric-label{font-size:12px;color:var(--muted);letter-spacing:.18em;text-transform:uppercase}
        .card-title{font-family:Georgia,serif;color:var(--gold);font-size:28px;line-height:1.04;margin:10px 0}
        .mono,pre{font-family:Consolas,Monaco,monospace;font-size:13px;line-height:1.55}
        pre{margin:0;white-space:pre-wrap;word-break:break-word;color:var(--text)}
        table{width:100%;border-collapse:collapse}
        th,td{text-align:left;padding:14px 12px;border-bottom:1px solid rgba(101,140,198,.12);vertical-align:top}
        th{color:var(--accent);letter-spacing:.18em;font-size:12px;text-transform:uppercase}
        .good{color:var(--good)} .warn{color:var(--warn)} .danger{color:var(--danger)}
        @media (max-width:1120px){.hero,.grid-2,.grid-3,.grid-4,.metrics{grid-template-columns:repeat(2,1fr)}}
        @media (max-width:780px){main{width:calc(100% - 20px);padding:14px}.hero,.grid-2,.grid-3,.grid-4,.metrics{grid-template-columns:1fr}h1{font-size:48px}}
      </style>
    </head>
    <body>
      <main>
        <section class="topbar">
          <div><span class="brand">VAPOR SAAS BILLING ENGINE</span><span class="lane">\(lane)</span></div>
          <div class="status">
            <span class="chip">MRR \(formatMoney(summary.monthlyRecurringRevenue))</span>
            <span class="chip">Dunning \(summary.dunningAccounts)</span>
            <span class="chip">Webhook events \(summary.processedWebhookEvents)</span>
          </div>
        </section>
        \(body)
      </main>
    </body>
    </html>
    """
}

func renderOverview(summary: BillingSummary, subscriptions: [AccountSubscription], invoices: [InvoiceRecord], webhooks: [WebhookEventRecord]) -> String {
    let leadInvoice = invoices.first { $0.state == "retrying" } ?? invoices[0]
    return pageShell(
        title: "Vapor SaaS Billing Engine",
        lane: "OVERVIEW LANE",
        current: "/",
        summary: summary,
        body: """
        <section class="hero">
          <article>
            <p class="eyebrow">Subscription economics</p>
            <h1>Subscription lifecycle, proration, and dunning all live in one operator-grade billing lane.</h1>
            <p class="lede">This Swift + Vapor service models the painful parts of SaaS billing that real operators actually care about: plan changes, preview math, payment-failure recovery, and webhook idempotency that prevents duplicate state transitions.</p>
          </article>
          <article>
            <div class="nav">
              <a class="active" href="/">Overview</a>
              <a href="/lifecycle">Lifecycle board</a>
              <a href="/verification">Webhook proof</a>
              <a href="/docs">Docs</a>
            </div>
            <p class="eyebrow">Lead recommendation</p>
            <h3>\(htmlEscaped(summary.leadRecommendation))</h3>
            <p>The revenue risk in this sample set is not missing invoices. It is recovery discipline around past-due enterprise accounts and making sure webhook replays do not double-apply billing changes.</p>
          </article>
        </section>
        <section class="metrics">
          <article class="metric"><div class="metric-label">Active subscriptions</div><strong>\(summary.activeSubscriptions)</strong><p>Accounts already recognized as live revenue.</p></article>
          <article class="metric"><div class="metric-label">Review accounts</div><strong>\(summary.reviewAccounts)</strong><p>Accounts needing human attention because of trial, downgrade, or payment posture.</p></article>
          <article class="metric"><div class="metric-label">Monthly recurring revenue</div><strong>\(formatMoney(summary.monthlyRecurringRevenue))</strong><p>Current MRR across the sample book.</p></article>
          <article class="metric"><div class="metric-label">Dunning accounts</div><strong>\(summary.dunningAccounts)</strong><p>Accounts actively sitting in payment recovery.</p></article>
        </section>
        <section class="grid-2">
          <article class="panel">
            <p class="eyebrow">Account posture</p>
            <h2>Which accounts are driving the billing story.</h2>
            <div class="grid-3">
              \(subscriptions.prefix(3).map { subscription in
                """
                <article class="card">
                  <span class="tag">\(htmlEscaped(subscription.status))</span>
                  <div class="card-title">\(htmlEscaped(subscription.company))</div>
                  <p>Plan \(htmlEscaped(subscription.planId)) · \(htmlEscaped(subscription.billingCycle)) billing · \(subscription.seats) seats.</p>
                  <p class="mono">renewal=\(htmlEscaped(subscription.renewalDate)) · payment_method=\(htmlEscaped(subscription.paymentMethodHealth))</p>
                </article>
                """
              }.joined())
            </div>
          </article>
          <article class="panel">
            <p class="eyebrow">Lead invoice</p>
            <h2>\(htmlEscaped(leadInvoice.recommendation))</h2>
            <p>\(htmlEscaped(leadInvoice.invoiceId)) is the best proof of why this repo matters: proration math, retry pressure, and clear operator actions all need to live together in one billing control surface.</p>
            <div class="tags">
              <span class="tag">\(htmlEscaped(leadInvoice.state)) state</span>
              <span class="tag">attempts \(leadInvoice.attemptCount)</span>
              <span class="tag">delta \(formatMoney(leadInvoice.prorationDelta))</span>
            </div>
          </article>
        </section>
        """
    )
}

func renderLifecycle(summary: BillingSummary, subscriptions: [AccountSubscription], invoices: [InvoiceRecord], webhooks: [WebhookEventRecord]) -> String {
    pageShell(
        title: "Lifecycle Board",
        lane: "LIFECYCLE BOARD",
        current: "/lifecycle",
        summary: summary,
        body: """
        <section class="hero">
          <article>
            <p class="eyebrow">Lifecycle board</p>
            <h1>The billing engine shows how plans, invoices, and recovery actions move together.</h1>
            <p class="lede">This board turns subscription state into an operating surface: which plan lane the account sits in, what invoice or proration event is shaping the next move, and which webhook outcome should or should not mutate state.</p>
          </article>
          <article>
            <div class="nav">
              <a href="/">Overview</a>
              <a class="active" href="/lifecycle">Lifecycle board</a>
              <a href="/verification">Webhook proof</a>
              <a href="/docs">Docs</a>
            </div>
            <p class="eyebrow">Signal lane</p>
            <h3>\(summary.processedWebhookEvents) lifecycle events are already in history.</h3>
            <p>That history becomes useful when the operator needs to explain whether an account moved because of a payment failure, a subscription change, or a harmless replay.</p>
          </article>
        </section>
        <section class="grid-2">
          <article class="panel">
            <p class="eyebrow">Subscriptions</p>
            <h2>Current book of business.</h2>
            <table>
              <thead><tr><th>Account</th><th>Status</th><th>Plan</th><th>MRR</th><th>Renewal</th></tr></thead>
              <tbody>
                \(subscriptions.map { sub in
                  "<tr><td>\(htmlEscaped(sub.company))</td><td>\(htmlEscaped(sub.status))</td><td>\(htmlEscaped(sub.planId))</td><td>\(formatMoney(sub.mrr))</td><td>\(htmlEscaped(sub.renewalDate))</td></tr>"
                }.joined())
              </tbody>
            </table>
          </article>
          <article class="panel">
            <p class="eyebrow">Invoices + proration</p>
            <h2>Why finance and product both care.</h2>
            <div class="grid-3">
              \(invoices.map { invoice in
                """
                <article class="card">
                  <span class="tag">\(htmlEscaped(invoice.state))</span>
                  <div class="card-title">\(htmlEscaped(invoice.invoiceId))</div>
                  <p>\(formatMoney(invoice.total)) · proration \(formatMoney(invoice.prorationDelta))</p>
                  <p>\(htmlEscaped(invoice.recommendation))</p>
                </article>
                """
              }.joined())
            </div>
          </article>
        </section>
        """
    )
}

func renderVerification(summary: BillingSummary, webhooks: [WebhookEventRecord]) -> String {
    let preview = """
    {
      "eventId": "evt_9901",
      "type": "invoice.payment_failed",
      "accountId": "acct-lattice",
      "amount": 4200,
      "idempotencyKey": "idemp_evt_9901"
    }
    """

    return pageShell(
        title: "Webhook Verification",
        lane: "WEBHOOK PROOF",
        current: "/verification",
        summary: summary,
        body: """
        <section class="hero">
          <article>
            <p class="eyebrow">Webhook proof</p>
            <h1>Exactly one billing change should happen, even when the webhook gets replayed.</h1>
            <p class="lede">The most important technical behavior in this repo is idempotency. Stripe-style events can be retried, delivered twice, or replayed after a timeout. The billing engine should still apply the change once and keep the account state trustworthy.</p>
          </article>
          <article>
            <div class="nav">
              <a href="/">Overview</a>
              <a href="/lifecycle">Lifecycle board</a>
              <a class="active" href="/verification">Webhook proof</a>
              <a href="/docs">Docs</a>
            </div>
            <p class="eyebrow">Operator takeaway</p>
            <h3>Duplicate webhook events are suppressed instead of mutating revenue twice.</h3>
            <p>That gives finance, support, and engineering one consistent story when they inspect lifecycle history.</p>
          </article>
        </section>
        <section class="grid-2">
          <article class="panel">
            <p class="eyebrow">Processed events</p>
            <h2>Recent webhook outcomes.</h2>
            <table>
              <thead><tr><th>Event</th><th>Type</th><th>Account</th><th>Processed</th><th>Outcome</th></tr></thead>
              <tbody>
                \(webhooks.prefix(5).map { event in
                  "<tr><td class=\"mono\">\(htmlEscaped(event.eventId))</td><td>\(htmlEscaped(event.type))</td><td>\(htmlEscaped(event.accountId))</td><td>\(event.processed ? "yes" : "duplicate")</td><td>\(htmlEscaped(event.outcome))</td></tr>"
                }.joined())
              </tbody>
            </table>
          </article>
          <article class="codebox">
            <p class="eyebrow">Simulation payload</p>
            <h2>POST /api/webhooks/stripe</h2>
            <pre>\(htmlEscaped(preview))</pre>
          </article>
        </section>
        """
    )
}

func renderDocs(summary: BillingSummary, plans: [SubscriptionPlan]) -> String {
    let spec = try? JSONSerialization.data(withJSONObject: OpenAPISpec.make(), options: [.prettyPrinted])
    let specString = spec.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

    return pageShell(
        title: "Docs",
        lane: "DOCS LANE",
        current: "/docs",
        summary: summary,
        body: """
        <section class="hero">
          <article>
            <p class="eyebrow">Docs lane</p>
            <h1>Small route surface, believable SaaS billing story.</h1>
            <p class="lede">This service keeps the surface area compact: dashboard summary, subscription inventory, invoice/proration lane, webhook history, and a simulation route that proves idempotent processing without needing a live Stripe dependency.</p>
          </article>
          <article>
            <div class="nav">
              <a href="/">Overview</a>
              <a href="/lifecycle">Lifecycle board</a>
              <a href="/verification">Webhook proof</a>
              <a class="active" href="/docs">Docs</a>
            </div>
            <p class="eyebrow">Plan shelf</p>
            <h3>\(plans.count) plans anchor the sample lifecycle.</h3>
            <p>The plan shelf is here mainly to prove that upgrades, downgrades, and proration can be explained in product language, not just in raw invoice math.</p>
          </article>
        </section>
        <section class="grid-2">
          <article class="panel">
            <p class="eyebrow">OpenAPI excerpt</p>
            <h2>Machine-readable contract</h2>
            <pre>\(htmlEscaped(specString))</pre>
          </article>
          <article class="panel">
            <p class="eyebrow">Plan definitions</p>
            <h2>Commercial lanes</h2>
            <div class="grid-3">
              \(plans.map { plan in
                """
                <article class="card">
                  <span class="tag">\(htmlEscaped(plan.targetBuyer))</span>
                  <div class="card-title">\(htmlEscaped(plan.label))</div>
                  <p>\(formatMoney(plan.monthlyPrice))/month · \(formatMoney(plan.annualPrice))/year</p>
                </article>
                """
              }.joined())
            </div>
          </article>
        </section>
        """
    )
}
