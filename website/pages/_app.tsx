import { useState } from "react";
import type { AppProps } from "next/app";
import { appWithTranslation } from "next-i18next";
import { Provider } from "react-redux";
import { PersistGate } from "redux-persist/integration/react";
import {
  ColorScheme,
  ColorSchemeProvider,
  MantineProvider,
} from "@mantine/core";
import { configureStore } from "../store";

import "../styles/globals.scss";

function MyApp({ Component, pageProps }: AppProps) {
  const { store, persistor } = configureStore();
  const [colorScheme, setColorScheme] = useState<ColorScheme>("light");
  const toggleColorScheme = (value?: ColorScheme) =>
    setColorScheme(value || (colorScheme === "dark" ? "light" : "dark"));

  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <ColorSchemeProvider
          colorScheme={colorScheme}
          toggleColorScheme={toggleColorScheme}
        >
          <MantineProvider
            withGlobalStyles
            withNormalizeCSS
            theme={{
              colorScheme,
              primaryColor: "indigo",
            }}
          >
            <Component {...pageProps} />
          </MantineProvider>
        </ColorSchemeProvider>
      </PersistGate>
    </Provider>
  );
}

export default appWithTranslation(MyApp);
