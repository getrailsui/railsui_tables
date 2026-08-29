import test from "node:test"
import assert from "node:assert/strict"
import TableExpandableController from "../../app/javascript/controllers/railsui_table_expandable_controller.js"

test("expands a detail row and assigns its frame source once", () => {
  const frame = {
    dataset: { src: "/users/7/details" },
    getAttribute: () => null,
    setAttribute(name, value) { this[name] = value }
  }
  const detail = {
    hidden: true,
    querySelector: () => frame
  }
  const button = {
    dataset: { detailId: "user_7_details" },
    getAttribute: () => "false",
    setAttribute(name, value) { this[name] = value }
  }
  const previousDocument = globalThis.document
  globalThis.document = { getElementById: () => detail }

  try {
    new TableExpandableController().toggle({ currentTarget: button, preventDefault() {} })
  } finally {
    globalThis.document = previousDocument
  }

  assert.equal(button["aria-expanded"], "true")
  assert.equal(detail.hidden, false)
  assert.equal(frame.src, "/users/7/details")
})
