import Foundation
import Models

public enum Accounts: Endpoint {
  case accounts(id: String)
  case favorites(sinceId: String?)
  case bookmarks(sinceId: String?)
  case followedTags
  case featuredTags(id: String)
  case verifyCredentials
  case updateCredentials(json: UpdateCredentialsData)
  case statuses(id: String,
                sinceId: String?,
                tag: String?,
                onlyMedia: Bool?,
                excludeReplies: Bool?,
                pinned: Bool?)
  case relationships(ids: [String])
  case follow(id: String, notify: Bool, reblogs: Bool)
  case unfollow(id: String)
  case familiarFollowers(withAccount: String)
  case suggestions
  case followers(id: String, maxId: String?)
  case following(id: String, maxId: String?)
  case lists(id: String)
  case preferences
  case block(id: String)
  case unblock(id: String)
  case mute(id: String, json: MuteData)
  case unmute(id: String)
  case relationshipNote(id: String, json: RelationshipNoteData)

  public func path() -> String {
    switch self {
    case let .accounts(id):
      return "accounts/\(id)"
    case .favorites:
      return "favourites"
    case .bookmarks:
      return "bookmarks"
    case .followedTags:
      return "followed_tags"
    case let .featuredTags(id):
      return "accounts/\(id)/featured_tags"
    case .verifyCredentials:
      return "accounts/verify_credentials"
    case .updateCredentials:
      return "accounts/update_credentials"
    case let .statuses(id, _, _, _, _, _):
      return "accounts/\(id)/statuses"
    case .relationships:
      return "accounts/relationships"
    case let .follow(id, _, _):
      return "accounts/\(id)/follow"
    case let .unfollow(id):
      return "accounts/\(id)/unfollow"
    case .familiarFollowers:
      return "accounts/familiar_followers"
    case .suggestions:
      return "suggestions"
    case let .following(id, _):
      return "accounts/\(id)/following"
    case let .followers(id, _):
      return "accounts/\(id)/followers"
    case let .lists(id):
      return "accounts/\(id)/lists"
    case .preferences:
      return "preferences"
    case let .block(id):
      return "accounts/\(id)/block"
    case let .unblock(id):
      return "accounts/\(id)/unblock"
    case let .mute(id, _):
      return "accounts/\(id)/mute"
    case let .unmute(id):
      return "accounts/\(id)/unmute"
    case let .relationshipNote(id, _):
      return "accounts/\(id)/note"
    }
  }

  public func queryItems() -> [URLQueryItem]? {
    switch self {
    case let .statuses(_, sinceId, tag, onlyMedia, excludeReplies, pinned):
      var params: [URLQueryItem] = []
      if let tag {
        params.append(.init(name: "tagged", value: tag))
      }
      if let sinceId {
        params.append(.init(name: "max_id", value: sinceId))
      }
      if let onlyMedia {
        params.append(.init(name: "only_media", value: onlyMedia ? "true" : "false"))
      }
      if let excludeReplies {
        params.append(.init(name: "exclude_replies", value: excludeReplies ? "true" : "false"))
      }
      if let pinned {
        params.append(.init(name: "pinned", value: pinned ? "true" : "false"))
      }
      return params
    case let .relationships(ids):
      return ids.map {
        URLQueryItem(name: "id[]", value: $0)
      }
    case let .follow(_, notify, reblogs):
      return [
        .init(name: "notify", value: notify ? "true" : "false"),
        .init(name: "reblogs", value: reblogs ? "true" : "false"),
      ]
    case let .familiarFollowers(withAccount):
      return [.init(name: "id[]", value: withAccount)]
    case let .followers(_, maxId):
      return makePaginationParam(sinceId: nil, maxId: maxId, mindId: nil)
    case let .following(_, maxId):
      return makePaginationParam(sinceId: nil, maxId: maxId, mindId: nil)
    case let .favorites(sinceId):
      guard let sinceId else { return nil }
      return [.init(name: "max_id", value: sinceId)]
    case let .bookmarks(sinceId):
      guard let sinceId else { return nil }
      return [.init(name: "max_id", value: sinceId)]
    default:
      return nil
    }
  }

  public var jsonValue: Encodable? {
    switch self {
    case let .mute(_, json):
      return json
    case let .relationshipNote(_, json):
      return json
    case let .updateCredentials(json):
      return json
    default:
      return nil
    }
  }
}

public struct MuteData: Encodable, Sendable {
  public let duration: Int

  public init(duration: Int) {
    self.duration = duration
  }
}

public struct RelationshipNoteData: Encodable, Sendable {
  public let comment: String

  public init(note comment: String) {
    self.comment = comment
  }
}

public struct UpdateCredentialsData: Encodable, Sendable {
  public struct SourceData: Encodable, Sendable {
    public let privacy: Visibility
    public let sensitive: Bool

    public init(privacy: Visibility, sensitive: Bool) {
      self.privacy = privacy
      self.sensitive = sensitive
    }
  }

  public struct FieldData: Encodable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
      self.name = name
      self.value = value
    }
  }

  public let displayName: String
  public let note: String
  public let source: SourceData
  public let bot: Bool
  public let locked: Bool
  public let discoverable: Bool
  public let fieldsAttributes: [String: FieldData]

  public init(displayName: String,
              note: String,
              source: UpdateCredentialsData.SourceData,
              bot: Bool,
              locked: Bool,
              discoverable: Bool,
              fieldsAttributes: [FieldData])
  {
    self.displayName = displayName
    self.note = note
    self.source = source
    self.bot = bot
    self.locked = locked
    self.discoverable = discoverable

    var fieldAttributes: [String: FieldData] = [:]
    for (index, field) in fieldsAttributes.enumerated() {
      fieldAttributes[String(index)] = field
    }
    self.fieldsAttributes = fieldAttributes
  }
}
