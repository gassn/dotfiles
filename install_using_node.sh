#!/bin/bash

# Install yarn.
npm install -g yarn
nodenv rehash

# Install amplify cli.
yarn global add @aws-amplify/cli

# Install serverless framework.
yarn global add serverless

