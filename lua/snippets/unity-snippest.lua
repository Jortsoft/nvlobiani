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

  -- Unity lifecycle extras
  s("onenable", {
    t({ "private void OnEnable()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ondisable", {
    t({ "private void OnDisable()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ondestroy", {
    t({ "private void OnDestroy()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),

  -- Unity GUI / gizmos
  s("ongui", {
    t({ "private void OnGUI()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ondrawgizmos", {
    t({ "private void OnDrawGizmos()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),
  s("ondrawgizmosselected", {
    t({ "private void OnDrawGizmosSelected()", "{" }),
    t({ "", "  " }), i(1),
    t({ "", "}" }),
  }),

  -- Coroutines
  s("coroutine", {
    t({ "private IEnumerator " }), i(1, "RoutineName"), t({ "()", "{" }),
    t({ "", "  yield return null;" }),
    t({ "", "}" }),
  }),
  s("startcoroutine", {
    t("StartCoroutine("), i(1, "RoutineName()"), t(");"),
  }),
  s("stopcoroutine", {
    t("StopCoroutine("), i(1, "RoutineName()"), t(");"),
  }),

  -- Component helpers
  s("getcomponent", {
    t("GetComponent<"), i(1, "ComponentType"), t(">();"),
  }),
  s("trygetcomponent", {
    t("TryGetComponent<"), i(1, "ComponentType"), t("> (out "), i(2, "component"), t(");"),
  }),
  s("getcomponentsinchildren", {
    t("GetComponentsInChildren<"), i(1, "ComponentType"), t(">();"),
  }),
  s("getcomponentsinparent", {
    t("GetComponentsInParent<"), i(1, "ComponentType"), t(">();"),
  }),

  -- Instantiate / Destroy
  s("instantiate", {
    t("Instantiate("), i(1, "prefab"), t(", "), i(2, "position"), t(", "), i(3, "rotation"), t(");"),
  }),
  s("destroy", {
    t("Destroy("), i(1, "gameObject"), t(");"),
  }),
  s("destroydelay", {
    t("Destroy("), i(1, "gameObject"), t(", "), i(2, "delay"), t(");"),
  }),

  -- Debug
  s("dlog", { t("Debug.Log("), i(1, "\"message\""), t(");") }),
  s("dlogw", { t("Debug.LogWarning("), i(1, "\"warning\""), t(");") }),
  s("dloge", { t("Debug.LogError("), i(1, "\"error\""), t(");") }),

  -- Attributes
  s("serializefield", { t("[SerializeField]") }),
  s("header", { t("[Header(\""), i(1, "Header"), t("\")]") }),
  s("range", { t("[Range("), i(1, "0"), t(", "), i(2, "1"), t(")]") }),
  s("requirecomponent", { t("[RequireComponent(typeof("), i(1, "Component"), t("))]") }),
  s("createassetmenu", {
    t({ "[CreateAssetMenu(menuName = \"" }), i(1, "Menu/Asset"), t({ "\", fileName = \"" }),
    i(2, "NewAsset"), t({ "\")]" }),
  }),
}
