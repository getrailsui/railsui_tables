import test from "node:test"
import assert from "node:assert/strict"
import RailsuiTableFilterController from "../../app/javascript/controllers/railsui_table_filter_controller.js"

test("submits the containing GET form", () => {
  let submitted = 0
  const controller = new RailsuiTableFilterController()
  controller.element = { requestSubmit: () => { submitted += 1 } }

  controller.submit()

  assert.equal(submitted, 1)
})
