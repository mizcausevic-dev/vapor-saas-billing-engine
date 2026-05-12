import Foundation
import Vapor

@main
struct VaporSaaSBillingEngine {
    static func main() async throws {
        let app = try await makeApp()
        try await app.execute()
    }
}

func makeApp() async throws -> Application {
    let env = try Environment.detect()
    let app = Application(env)
    let port = Environment.get("PORT").flatMap(Int.init) ?? 4624
    app.http.server.configuration.hostname = "127.0.0.1"
    app.http.server.configuration.port = port

    let store = BillingStore()

    app.get { req async throws -> Response in
        let dashboard = await store.dashboard()
        let html = renderOverview(
            summary: dashboard.summary,
            subscriptions: dashboard.subscriptions,
            invoices: dashboard.invoices,
            webhooks: dashboard.webhooks
        )
        return htmlResponse(req: req, html: html)
    }

    app.get("lifecycle") { req async throws -> Response in
        let dashboard = await store.dashboard()
        let html = renderLifecycle(
            summary: dashboard.summary,
            subscriptions: dashboard.subscriptions,
            invoices: dashboard.invoices,
            webhooks: dashboard.webhooks
        )
        return htmlResponse(req: req, html: html)
    }

    app.get("verification") { req async throws -> Response in
        let dashboard = await store.dashboard()
        let html = renderVerification(summary: dashboard.summary, webhooks: dashboard.webhooks)
        return htmlResponse(req: req, html: html)
    }

    app.get("docs") { req async throws -> Response in
        let summary = await store.summary()
        let plans = await store.plansList()
        let html = renderDocs(summary: summary, plans: plans)
        return htmlResponse(req: req, html: html)
    }

    app.get("openapi.json") { req async throws -> Response in
        let json = try JSONSerialization.data(withJSONObject: OpenAPISpec.make(), options: [.prettyPrinted])
        let response = Response(status: .ok, body: .init(data: json))
        response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }

    app.group("api") { api in
        api.get("dashboard", "summary") { _ async throws -> BillingSummary in
            await store.summary()
        }

        api.get("subscriptions") { _ async throws -> [AccountSubscription] in
            await store.subscriptionsList()
        }

        api.get("invoices") { _ async throws -> [InvoiceRecord] in
            await store.invoicesList()
        }

        api.get("webhooks") { _ async throws -> [WebhookEventRecord] in
            await store.webhookEventsList()
        }

        api.get("sample") { _ async throws -> BillingDashboard in
            await store.dashboard()
        }

        api.post("webhooks", "stripe") { req async throws -> WebhookSimulationResult in
            let payload = try req.content.decode(WebhookSimulationInput.self)
            return await store.simulateWebhook(payload)
        }
    }

    return app
}

private func htmlResponse(req: Request, html: String) -> Response {
    let response = Response(status: .ok, body: .init(string: html))
    response.headers.replaceOrAdd(name: .contentType, value: "text/html; charset=utf-8")
    return response
}
