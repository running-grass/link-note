import { gql } from '@apollo/client';

export const QUERY_LAUNCH_LIST = gql`
  query Topic {
    topic(id: 1) {
      id
      title
    }
  }
`;