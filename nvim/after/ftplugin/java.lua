local java_home = os.getenv("JAVA_HOME")
local home = os.getenv("HOME")
local jdtls = require("jdtls")
local config = {
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. home .. "/.local/share/java/lombok.jar",
    "-data",
    home .. "/.cache/jdtls/workspace",
  },
  root_dir = vim.fs.dirname(
    vim.fs.find({ "gradlew", ".git", "mvnw", "pom.xml", ".jj" }, { upward = true })[1]
  ),
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
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
        referencesCodeLens = {
          enabled = true,
        },
        completion = {
          favoriteStaticMembers = {
            "org.assertj.core.api.Assertions.assertThat",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
            "java.util.Stream.Collectors.*",
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*",
            "sun.*",
          },
        },
      },
    },
  },
  capabilities = require("saep.lsp").capabilities,
  on_attach = function(client, bufnr)
    require("saep.lsp").on_attach(client, bufnr)
    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.java" },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end,
    })
    vim.lsp.codelens.refresh()
  end,
}
jdtls.start_or_attach(config)
