export const RunStatus = {
  Cancelled: { Cancelled: null },
  InProgress: { InProgress: null },
  Expired: { Expired: null },
  Completed: { Completed: null },
  Failed: { Failed: null },
};

export const MessageType = {
  User: { User: null },
  System: { System: null },
};

export const ResourceType = {
  Book: { Book: null },
  Article: { Article: null },
  Slides: { Slides: null },
  Video: { Video: null },
};

export const ResourceTypes = Object.keys(ResourceType);

export const getEnum = (/** @type {{}} */ option, /** @type {{}} */ enumObject) => {
  for (let key of Object.keys(enumObject)) {
    if (key === Object.keys(option)[0]) {
      return key;
    }
  }
};
