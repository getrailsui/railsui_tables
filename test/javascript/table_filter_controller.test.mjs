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

test("submits on input after the debounce delay", async () => {
  let submitted = 0
  const handlers = {}
  const controller = new RailsuiTableFilterController()
  controller.element = {
    requestSubmit: () => { submitted += 1 },
    addEventListener: (type, fn) => { handlers[type] = fn },
    removeEventListener: () => {}
  }
  controller.delayValue = 0
  controller.autoValue = true
  controller.connect()

  assert.equal(typeof handlers.input, "function")
  handlers.input() // simulate typing
  await new Promise((resolve) => setTimeout(resolve, 5))

  assert.equal(submitted, 1)
})

test("does not auto-submit when auto is false", () => {
  const handlers = {}
  const controller = new RailsuiTableFilterController()
  controller.element = {
    requestSubmit: () => {},
    addEventListener: (type, fn) => { handlers[type] = fn },
    removeEventListener: () => {}
  }
  controller.autoValue = false
  controller.connect()

  assert.equal(handlers.input, undefined)
})
