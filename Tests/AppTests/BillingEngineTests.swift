import XCTVapor
@testable import App

final class BillingEngineTests: XCTestCase {
    func testSummaryEndpoint() async throws {
        let app = try await makeApp()
        defer { app.shutdown() }

        try app.test(.GET, "/api/dashboard/summary") { response in
            XCTAssertEqual(response.status, .ok)
            let summary = try response.content.decode(BillingSummary.self)
            XCTAssertGreaterThan(summary.monthlyRecurringRevenue, 0)
            XCTAssertGreaterThanOrEqual(summary.processedWebhookEvents, 3)
        }
    }

    func testWebhookSimulationProcessesOnce() async throws {
        let app = try await makeApp()
        defer { app.shutdown() }

        let payload = WebhookSimulationInput(
            eventId: "evt_test_01",
            type: "invoice.payment_failed",
            accountId: "acct-lattice",
            amount: 4200,
            idempotencyKey: "idemp_evt_test_01"
        )

        try app.test(.POST, "/api/webhooks/stripe", beforeRequest: { request in
            try request.content.encode(payload)
        }, afterResponse: { response in
            let result = try response.content.decode(WebhookSimulationResult.self)
            XCTAssertFalse(result.duplicate)
            XCTAssertEqual(result.outcome, "processed")
        })

        try app.test(.POST, "/api/webhooks/stripe", beforeRequest: { request in
            try request.content.encode(payload)
        }, afterResponse: { response in
            let result = try response.content.decode(WebhookSimulationResult.self)
            XCTAssertTrue(result.duplicate)
            XCTAssertEqual(result.outcome, "duplicate_ignored")
        })
    }
}
