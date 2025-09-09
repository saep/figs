local java_home = os.getenv("JAVA_HOME")
local home = os.getenv("HOME")
local jdtls = require("jdtls")

local runtimes = {}
if java_home and string.match(java_home, "jdk[-]11[.]") then
  table.insert(runtimes, {
    name = "JavaSE-11",
    path = java_home,
  })
end
if java_home and string.match(java_home, "jdk[-]21[.]") then
  table.insert(runtimes, {
    name = "JavaSE-21",
    path = java_home,
  })
end

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
        runtimes = runtimes,
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
    local opts = function(desc, args)
      local opts = { silent = true, buffer = bufnr, desc = desc }
      if args then
        for key, value in pairs(args) do
          opts[key] = value
        end
      end
      return opts
    end
    vim.keymap.set("n", "<Leader>o", jdtls.organize_imports, opts("organize imports"))
    vim.keymap.set("n", "<Leader>tt", jdtls.test_nearest_method, opts("test nearest method"))
    vim.keymap.set("n", "<Leader>tc", jdtls.test_class, opts("test nearest method"))
    vim.lsp.codelens.refresh()
  end,
}

local vs_code_extensions_dir = home .. "/.local/share/vscode/extensions"
local bundles = {}

vim.list_extend(
  bundles,
  vim.fn.glob(
    vs_code_extensions_dir
      .. "/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar",
    false,
    true
  )
)
vim.list_extend(
  bundles,
  vim.fn.glob(vs_code_extensions_dir .. "/vscjava.vscode-java-test/server/*.jar", false, true)
)

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
config.init_options = {
  bundles = bundles,
  extendedClientCapabilities = extendedClientCapabilities,
}

jdtls.start_or_attach(config)
