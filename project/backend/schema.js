const { gql } = require('graphql-tag');

const typeDefs = gql`
  scalar JSON

  type Geometry {
    type: String!
    coordinates: JSON!
  }

  type State {
    id: ID!
    name: String!
    geometry: Geometry!
  }

  type Query {
    states(name: String!): [State!]!
  }
`;

module.exports = { typeDefs };
