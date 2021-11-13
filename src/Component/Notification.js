exports._requestPermission = () => {
   return Notification.requestPermission();
};

exports.notify = title => () => {
   return new Notification(title);
};