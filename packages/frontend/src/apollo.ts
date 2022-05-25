import { SdkType, getSdk } from "./generated/apollo";
import { setContext } from '@apollo/client/link/context';

import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";

const httpLink = createHttpLink({
  uri: process.env.REACT_APP_APOLLO_CLIENT_URI,
});

const authLink = setContext((_, { headers }) => {
  // get the authentication token from local storage if it exists
  const token = localStorage.getItem('access_token');
  console.log(token)
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      Authorization: token ? `Bearer ${token}` : "",
    }
  }
});

export const client = new ApolloClient({
  // uri: process.env.REACT_APP_APOLLO_CLIENT_URI,
  cache: new InMemoryCache(),
  // link: authLink,
  link: authLink.concat(httpLink),

  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'network-only',
    }
  }
});


export const sdk: SdkType = getSdk(client);