local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Unity 2D triggers/collisions
  s("ontriggerenter2d", {
    t({ "private void OnTriggerEnter2D(Collider2D other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ontriggerexit2d", {
    t({ "private void OnTriggerExit2D(Collider2D other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ontriggerstay2d", {
    t({ "private void OnTriggerStay2D(Collider2D other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionenter2d", {
    t({ "private void OnCollisionEnter2D(Collision2D collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionexit2d", {
    t({ "private void OnCollisionExit2D(Collision2D collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionstay2d", {
    t({ "private void OnCollisionStay2D(Collision2D collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),

  -- Unity 3D triggers/collisions
  s("ontriggerenter", {
    t({ "private void OnTriggerEnter(Collider other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ontriggerexit", {
    t({ "private void OnTriggerExit(Collider other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ontriggerstay", {
    t({ "private void OnTriggerStay(Collider other)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionenter", {
    t({ "private void OnCollisionEnter(Collision collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionexit", {
    t({ "private void OnCollisionExit(Collision collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("oncollisionstay", {
    t({ "private void OnCollisionStay(Collision collision)", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),

  -- Unity lifecycle
  s("start", {
    t({ "private void Start()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("awake", {
    t({ "private void Awake()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("update", {
    t({ "private void Update()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("fixedupdate", {
    t({ "private void FixedUpdate()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("lateupdate", {
    t({ "private void LateUpdate()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
}
