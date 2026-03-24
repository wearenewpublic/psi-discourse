# frozen_string_literal: true

# Routes for the PSI engine: vote casting, removal, and retrieval endpoints.
Psi::Engine.routes.draw do
  put "/vote" => "slider#vote"
  delete "/vote" => "slider#remove_vote"
  get "/votes/:topic_id" => "slider#votes"
end
