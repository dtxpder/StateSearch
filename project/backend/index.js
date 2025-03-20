require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const { ApolloServer } = require('@apollo/server');
const { expressMiddleware } = require('@apollo/server/express4');
const { typeDefs } = require('./schema');
const { GraphQLJSON } = require('graphql-type-json');

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('MongoDB connected'))
    .catch(err => console.error(err));

// Mongoose Schema
const stateSchema = new mongoose.Schema({}, { strict: false });
const StateModel = mongoose.model('states', stateSchema);


const resolvers = {
    Query: {
        states: async (_, { name }) => {
            const searchPattern = name.trim().split('').join('.*?');

            return StateModel
                .find({ 'properties.name': { $regex: searchPattern, $options: 'i' } })
                .collation({ locale: 'en' })
                .sort({ 'properties.name': 1 });
        },
    },
    State: {
        id: parent => parent._id,
        name: parent => parent.properties.name,
        geometry: parent => parent.geometry,
    },
};


const server = new ApolloServer({ typeDefs, resolvers });

async function startServer() {
    await server.start();

    app.use('/graphql', expressMiddleware(server));

    app.listen(process.env.PORT, () => {
        console.log(`Server running at http://localhost:${process.env.PORT}/graphql`);
    });
}

startServer();
