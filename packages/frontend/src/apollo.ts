import { SdkType, getSdk } from "./generated/apollo";

import { ApolloClient, InMemoryCache } from "@apollo/client";


export const client = new ApolloClient({
  uri: "/api/graphql",
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'network-only',
    }
  }
});


export const sdk: SdkType = getSdk(client);