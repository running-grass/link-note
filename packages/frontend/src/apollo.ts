import { SdkType, getSdk } from "./generated/apollo";

import { ApolloClient, InMemoryCache } from "@apollo/client";


export const client = new ApolloClient({
  uri: process.env.REACT_APP_APOLLO_CLIENT_URI,
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'network-only',
    }
  }
});


export const sdk: SdkType = getSdk(client);