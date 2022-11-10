const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

type Msg = {
    tid: string;
    nameTalk: string;
    time: string;
    text: string;
    uid: string;
    nameUser: string;
    tokenReceiver:String;
}

exports.notificationChat = functions.database.ref('/msg/{uid}/{uid_time}')
    .onCreate((snap:any, context:any) => {
        const msg:Msg = snap.val()
        const tokenReceiver = msg.tokenReceiver
        if(tokenReceiver == null)return;
        const payload = {
            token: tokenReceiver,
            notification: {
                title: '' + msg.nameUser,
                body: '' + msg.text
            },
            data: {...msg,
                'category' : 'chat'
            }
        };
        console.log(payload);
        admin.messaging().send(payload).then((response:any) => {
            // Response is a message ID string.
            console.log('sent message chat from:',msg.uid , " to:" , tokenReceiver);
            return {success: true};
        }).catch((error:any) => {
            console.log(error);
            return {error: error.code};
        });
    });

exports.onLike = functions.database.ref('/like/{uidReceiver}/{uidHandler}')
    .onCreate((snap:any, context:any) => {
        console.log('like one create');
        console.log(snap);
        const tokenHandler = snap.val();
        const uidHandler:string = context.params.uidHandler
        const uidReceiver:string = context.params.uidReceiver

        console.log(uidHandler)
        console.log(tokenHandler)
        console.log(uidReceiver)

        if(uidHandler == null || uidReceiver == null){return}

        admin.database()
        .ref('/like/' + uidHandler + '/' + uidReceiver).once('value').then(function(snap:any){
            if (snap.exists()) {
                console.log("match : " + uidHandler + ' - ' + uidReceiver);
                const tokenReceiver:string = snap.val()
                admin.database().ref('/match/' + uidReceiver + '/' + uidHandler).set(tokenReceiver);
                admin.database().ref('/match/' + uidHandler + '/' + uidReceiver).set(tokenHandler);
                //pushMatch(tokenReceiver,uidHandler);
                //pushMatch(tokenHandler,uidReceiver);
            } else {
                console.log("No data available");
            }
        });
    });

exports.notificationMatch = functions.database.ref('/match/{uidReceiver}/{uidHandler}')
.onCreate((snap:any, context:any) => {
    const token = snap.val();
    const uid = context.params.uidHandler;
    admin.database().ref('/user/' + uid + '/name').once('value').then(function(snap:any){
        if (snap.exists()) {
            const name:string = snap.val()
            const payload = {
                token: token,
                notification: {
                    title: 'マッチングしました！',
                    body: '' + name + 'とマッチしました。',
                },
                data: {
                    'category' : 'match',
                    'uid':uid
                },
                apns: {
                      payload: {
                        aps: {
                          contentAvailable: true,
                        },
                      },
                      headers: {
                        //"apns-push-type": "background", // This line prevents background notification
                        "apns-priority": "10",
                      },
                    }
            };
            admin.messaging().send(payload).then((response:any) => {
                // Response is a message ID string.
                console.log('sent match:', response, ' uid:', uid , " token:" , token);
                return {success: true};
            }).catch((error:any) => {
                console.log(error);
                return {error: error.code};
            });
        } else {
            console.log("No data available");
        }
    });
});

// type Event = {
//     comment:string;
//     host:string;
//     listTag:[string];
//     member:[string]
//     numMax:number
//     place:string,
//     time:string,
//     title:string,
//     urlIcon:string,
// }

// exports.notificationMatch = functions.database.ref('/event/{eid}/{listLike}/{uid}')
// .onCreate((snap:any, context:any) => {
//     const uid:string = context.params.uid
//     const data:{time:string,tokenHost:string} = snap.val();
//     const tokenHost:string = data.tokenHost
//
//     const payload = {
//         token: tokenHost,
//         notification: {
//             title: 'いいねされました',
//         },
//         data: {
//             'category' : 'event',
//             'uid':uid
//         },
//         apns: {
//           payload: {
//             aps: {
//               contentAvailable: true,
//             },
//           },
//           headers: {
//             //"apns-push-type": "background", // This line prevents background notification
//             "apns-priority": "10",
//           },
//         }
//     };
//     admin.messaging().send(payload).then((response:any) => {
//         // Response is a message ID string.
//         console.log('sent event');
//         return {success: true};
//     }).catch((error:any) => {
//         console.log(error);
//         return {error: error.code};
//     });
// });

exports.noticeSwichatMatch = functions.database.ref('/swichatMatch/{uidHandler}')
.onWrite((change: any, context : any) => {
    const uidHandler :string = context.params.uidHandler;
    if(change.after.exists()){
        const data = change.after.val();
        const tokenHandler = data.tokenHandler
        const uidPartner = data.uid
        if(uidHandler == uidPartner)return
        const payload = {
           token : tokenHandler,
           notification: {
               title: 'マッチングしました！',
           },
           data : {
               'category' : 'swichat',
               'action':'match',
               'uid':uidPartner
           }
       }
       admin.messaging().send(payload).then((response:any) => {
           console.log('sent swichat payload ' + payload);
           return {success: true};
       }).catch((error:any) => {
           console.log(error);
           return {error: error.code};
       });
       admin.database().ref('/swichatInvite/' + uidHandler).remove()
    }else{
        const dataBefore = change.before.val()
        const uidBefore = dataBefore.uid
        if(uidHandler == uidBefore)return
        const payload = {
            token : dataBefore.token,
            data : {
                'category' : 'swichat',
                'action':'switch'
            }
        }

        admin.messaging().send(payload).then((response:any) => {
            // Response is a message ID string.
            console.log('sent swichat payload ' + payload);
            return {success: true};
        }).catch((error:any) => {
            console.log(error);
            return {error: error.code};
        });
    }
});

exports.noticeSwichatInvite = functions.database.ref('/swichatInvite/{uidHandler}')
.onWrite((change : any, context : any) => {
    const uidHandler :string = context.params.uidHandler;
    let data = change.after.val()
    let tokenHandler = data.tokenHandler
    let tokenReceiver = data.token
    if(change.after.exists()){
        const uidReceiver = data.uid
        const timeNow = new Date()
        console.log(timeNow);
        const strYear = '' + timeNow.getFullYear();
        const strMonth = String(timeNow.getMonth() + 1).padStart(2, '0');
        const strDay = String(timeNow.getDate()).padStart(2, '0');
        const strHour = String(timeNow.getHours()).padStart(2, '0');
        const strMinutes = String(timeNow.getMinutes()).padStart(2, '0');
        const strSeconds = String(timeNow.getSeconds()).padStart(2, '0');
        const strMilliseconds = String(timeNow.getMilliseconds()).padStart(3, '0');
        const strTime = strYear + strMonth + strDay + strHour + strMinutes + strSeconds + strMilliseconds;
        console.log(strTime);

        admin.database().ref('/swichatMatch/' + uidReceiver).once('value').then(function(snap:any){
            if(!snap.exists()){
                admin.database().ref('/swichatMatch/' + uidHandler).set({
                    'token' : tokenReceiver,
                    'tokenHandler' : tokenHandler,
                    'uid' : uidReceiver,
                    'timeMatch' : strTime
               });

               admin.database().ref('/swichatMatch/' + uidReceiver).set({
                    'token' : tokenHandler,
                    'tokenHandler' : tokenReceiver,
                    'uid' : uidHandler,
                    'timeMatch' : strTime
               });
            }
        })

    }
})



