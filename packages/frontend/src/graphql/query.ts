import { gql } from '@apollo/client';

export const QUERY_LAUNCH_LIST = gql`
  query findTopic{
    topic(id: 1) {
      id
      title
    }
  }
`;

export const QUERY_TOPIC_LIST = gql`
  query findTopics($search: String, $limit: Int){
    topics (search: $search, limit: $limit) {
      id
      title
    }
  }
`;

export const MUTATION_CREATE_TOPIC = gql`
  mutation createTopic($title: String!){
    createTopic(title: $title) {
      id
      title
    }
  }
`