# frozen_string_literal: true

Psi::Engine.routes.draw do
  put "/vote" => "slider#vote"
  delete "/vote" => "slider#remove_vote"
  get "/votes/:topic_id" => "slider#votes"
end
