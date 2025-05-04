local java_home = os.getenv("JAVA_HOME")
local config = {
  cmd = { "jdtls" },
  root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
  settings = {
    java = {
      configuration = {
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- And search for `interface RuntimeOption`
        -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
        runtimes = {
          {
            name = "JavaSE-11",
            path = java_home,
          },
          {
            name = "JavaSE-17",
            path = java_home,
          },
          {
            name = "JavaSE-21",
            path = java_home,
          },
        },
      },
    },
  },
}
require("jdtls").start_or_attach(config)
require("saep.lsp").on_attach(nil, vim.api.nvim_get_current_buf())
