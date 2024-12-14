local function copy(args)
  return args[1]
end

return {

  s(",hspec (test module)", {
    t({ "import Test.Hspec", "", "spec :: Spec", "spec = do", '    describe "' }),
    i(1, ""),
    t({ '" $ do', '        it "' }),
    i(2, ""),
    t({ '" $ do', "            " }),
    i(0, "True `shouldBe` False"),
  }),
  s(",it (hspec it)", {
    t('it "'),
    i(1, ""),
    t({ '" $ do', "    " }),
    i(0, "True `shouldBe` False"),
  }),
  s(",data", {
    t("data "),
    i(1, "Name"),
    t(" = "),
    i(0),
  }),
  s(",record", {
    t("data "),
    i(1, "Name"),
    t(" = "),
    f(copy, { 1 }),
    t({ "", "    { " }),
    i(2, "field"),
    t(" :: "),
    i(3, "Type"),
    t({ "", "    }" }),
    i(0),
  }),
  s(",deriving", {
    t("deriving ("),
    c(1, {
      i(1, "Show"),
      i(1, "Show, Eq"),
      i(1, "Show, Eq, Generic"),
    }),
    i(2),
    t(")"),
    i(0),
  }),
  s(",instance", {
    t("instance "),
    i(1, "Class Type"),
    t(" where"),
    t({ "", "    " }),
    i(2, "method"),
    t(" = "),
    i(0, "undefined"),
  }),
  s(",newtype", {
    t("newtype "),
    i(1, "Name"),
    t(" = "),
    d(2, function(args, parent)
      return sn(
        nil,
        c(1, {
          t(args[1]),
          sn(nil, {
            t("{ un"),
            t(args[1]),
            t(" :: "),
            i(1, "WrappedType"),
            t(" }"),
          }),
        })
      )
    end, { 1 }),
    i(0),
  }),
}, {}
