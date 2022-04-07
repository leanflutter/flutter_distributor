import { useMemo } from "react";
import { createStore, applyMiddleware, Action, Store, compose } from "redux";
import { composeWithDevTools } from "redux-devtools-extension";
import {
  PersistConfig,
  Persistor,
  persistReducer,
  persistStore,
} from "redux-persist";
import storage from "redux-persist/lib/storage";

export interface AppState {
  user: any;
  value: number;
}

let _store: Store<AppState> | undefined;
let _persistor: Persistor | undefined;

const exampleInitialState: AppState = {
  user: null,
  value: 0,
};

export const actionTypes = {
  LOGIN: "LOGIN",
  LOGOUT: "LOGOUT",
};

// REDUCERS
export const reducer = (state: AppState = exampleInitialState, action: any) => {
  switch (action.type) {
    case actionTypes.LOGIN:
      return {
        ...state,
        user: action.user,
      };
    case actionTypes.LOGOUT:
      return {
        ...state,
        user: null,
      };
    default:
      return state;
  }
};

// ACTIONS
export const login = (user: any) => {
  return { type: actionTypes.LOGIN, user };
};
export const logout = () => {
  return { type: actionTypes.LOGOUT };
};

const persistConfig: PersistConfig<AppState, any> = {
  key: "primary",
  storage,
  whitelist: ["user"], // place to select which state you want to persist
};

const persistedReducer = persistReducer(persistConfig, reducer);

function makeStore(initialState: any = exampleInitialState): Store<AppState> {
  return createStore(
    persistedReducer,
    initialState,
    composeWithDevTools(applyMiddleware())
  );
}

export const configureStore = () => {
  if (_store == undefined) _store = makeStore();
  if (_persistor == undefined) _persistor = persistStore(_store);
  return { store: _store, persistor: _persistor };
};
