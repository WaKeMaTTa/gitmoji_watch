require 'spec_helper'

RSpec.describe GitmojiWatch do
  let(:contributor_1) {
    Hash.new({
      author: 'Contributor 1',
      email: 'contributor1@exmple.com'
    })
  }

  let(:contributor_2) {
    Hash.new({
      author: 'Contributor 2',
      email: 'contributor2@exmple.com'
    })
  }

  let(:emoji_points) {
    Hash.new({
      tada: 1,
      art: 10,
      memo: 2,
      heavy_plus_sign: -5
    })
  }

  let(:user_repository_url) {
    String.new('https://github.com/user1/repo')
  }

  let(:organization_repository_url) {
    String.new('https://github.com/organization/repo')
  }

  let(:commits_of_user_repository) {
    Array.new([
      {
        title: ':tada: My first commit',
        commit: 'HASH-COMMIT-001',
        author: 'Contributor 1',
        email: 'contributor1@example.com'
      },
      {
        title: ':sparkles: Introducing new features.',
        commit: 'HASH-COMMIT-002',
        author: 'Contributor X',
        email: 'contributorx@example.com'
      },
    ])
  }

  let(:commits_of_organization_repository) {
    Array.new([
      {
        title: ':tada: Initial commit',
        commit: 'HASH-COMMIT-101',
        author: 'Contributor 2',
        email: 'contributor2@example.com'
      },
      {
        title: ':art: Improve some code',
        commit: 'HASH-COMMIT-102',
        author: 'Contributor 2',
        email: 'contributor2@example.com'
      },
      {
        title: ':art: More code improved.',
        commit: 'HASH-COMMIT-103',
        author: 'Contributor 2',
        email: 'contributor2@example.com'
      },
      {
        title: ':sparkles: New feature!',
        commit: 'HASH-COMMIT-104',
        author: 'Contributor 1',
        email: 'contributor1@example.com'
      },
    ])
  }

  it 'has a version number' do
    expect(GitmojiWatch::VERSION).not_to be nil
  end

  it 'add repository' do
    gw = GitmojiWatch.new
    expect{
      gw.add_repository(user_repository_url)
    }.to eq([user_repository_url])
    expect{
      gw.add_repository(organization_repository_url)
    }.to eq([user_repository_url, organization_repository_url])
  end

  it 'get all repositories added' do
    gw = GitmojiWatch.new
    expect(gw.repositories).to eq([])

    gw.add_repository(user_repository_url)
    expect(gw.repositories).to eq([user_repository_url])
  end

  it 'get a hash of commits' do
    gw = GitmojiWatch.new
    expect(gw.commits).to eq([])

    gw.add_repository(user_repository_url)
    expect(gw.commits).to eq(commits_of_user_repository)
  end

  it 'set points for each emoji' do
    emoji_points =

    gw = GitmojiWatch.new
    expect(gw.emoji_points).to eq({})

    gw = GitmojiWatch.new(emoji_points: emoji_points)
    expect(gw.emoji_points).to eq(emoji_points)
  end

  it 'make the calculations for each contributor in X repositories.' do
    gw = GitmojiWatch.new(emoji_points: emoji_points)
    expect(gw.process).to eq(false)

    gw.add_repository(user_repository_url)
    expect(gw.process).to eq(true)
  end

  it 'make the calculations for each contributor in X repositories. (raise error)' do
    gw = GitmojiWatch.new(emoji_points: emoji_points)
    expect(gw.process!).to raise_error(GitmojiWatchError,
      'Can not be processed because you did not set any repository.')

    gw.add_repository(user_repository_url)
    expect(gw.process!).to eq(nil)
  end

  it 'get a list of points for each contributor' do
    gw = GitmojiWatch.new(emoji_points: emoji_points)
    gw.add_repository(user_repository_url)
    expect(gw.total_points).to eq([{
      'contributor1@example.com' => 1,
      'contributorx@example.com' => 0,
    }])
  end

  it 'get a list of emoji utilized for each contributor' do
    gw = GitmojiWatch.new(emoji_points: emoji_points)
    gw.add_repository(commits_of_organization_repository)
    expect(gw.emoji_utilized_by_contributor).to eq([{
      'contributor1@example.com' => [:sparkles],
      'contributor2@example.com' => [:tada, :art],
    }])
  end

  it 'get a list of emoji with times utilized for each contributor' do
    gw = GitmojiWatch.new(emoji_points: emoji_points)
    gw.add_repository(commits_of_organization_repository)
    expect(gw.total_points_for_each_emoji).to eq([{
      'contributor1@example.com' => {sparkles: 0},
      'contributor2@example.com' => {tada: 1, art: 2},
    }])
  end
end
