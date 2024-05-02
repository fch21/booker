import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer'; // Corrigido a importação de nodemailer
import twilio from 'twilio';
import {DocumentSnapshot, WriteResult} from 'firebase-admin/firestore'; // Corrigido a importação de DocumentSnapshot


admin.initializeApp();

let transporter = nodemailer.createTransport({
    service: 'gmail', // Example with Gmail. Change as per your email service.
    auth: {
        user: 'central.booker@gmail.com',
        pass: functions.config().nodemailer.password,
    },
});

const accountSid = functions.config().twilio.sid;
//const accountSid = functions.config().twilio.testsid;
const authToken = functions.config().twilio.token;
//const authToken = functions.config().twilio.testtoken;
const whatsappNumber = 'whatsapp:+16417159271';

const twilioClient = twilio(accountSid, authToken);
const express = require('express');
//const stripe = require("stripe")(functions.config().stripe.testkey);
const stripe = require("stripe")(functions.config().stripe.livekey);
// Endpoint para webhooks do Stripe
const app = express();
//const endpointSecret = functions.config().stripe.whkey;//test
const endpointSecret = functions.config().stripe.whkeylive;
//const premiumSubscriptionPrice = "price_1OoI0aAnghrwvGGz3EMWcLiw"; //test
const premiumSubscriptionPrice = "price_1PBziMAnghrwvGGzJRVeSZDO"; //live
const cors = require("cors");
const corsOptions = {
  origin: true,
  methods: ["GET", "POST"],
  allowedHeaders: ["Content-Type", "Authorization"],
};
const corsMiddleware = cors(corsOptions);

//cors
async function verifyToken(req:any) {
  const authorizationHeader = req.headers.authorization || "";
  const components = authorizationHeader.split(" ");

  //console.log("req.headers:", req.headers);
  //console.log("authorizationHeader:", authorizationHeader);
  console.log("components:", components);
  if (components.length === 2 && components[0] === "Bearer") {
    const token = components[1];
    //console.log("token:", token);
    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      console.log("decodedToken:", decodedToken);
      //console.log("Current user uid:", decodedToken.uid);
      return {uid: decodedToken.uid, error: null};
    } catch (error) {
      console.error("Erro ao verificar o token:", error);
      return {uid: null, error: "Acesso não autorizado"};
    }
  }

  return {uid: null, error: "Acesso não autorizado"};
}

//utils
function formatDateStringToMessage(dateString: string): string {
    const parts = dateString.split("-");
    return `${parts[2]}/${parts[1]}/${parts[0]}`;
}

function formatDateToString(date: Date): string {
  // Formata a data para o padrão ISO, corta para o tamanho desejado e substitui 'T' por espaço
  return date.toISOString().slice(0, 16).replace('T', ' ');
}

//email
function sendEmail(to: string, subject: string, text: string) {
    const mailOptions = {
        from: 'central.booker@gmail.com', // Substitua pelo seu e-mail de envio
        to,
        subject,
        text,
    };

    return transporter.sendMail(mailOptions)
        .then((info) => {
            console.log('Email sent: ' + info.response);
            return info;
        })
        .catch((error) => {
            console.log('Error sending email:', error);
            throw error;
        });
}

//twilio
function sendWhatsAppMessage(to: string, templateSid: string, variables: any) {
    console.log('sendWhatsAppMessage to:', to);
    console.log('sendWhatsAppMessage whatsappNumber:', whatsappNumber);

    return twilioClient.messages.create({
        //body: body,
        //to: `whatsapp:${to}`,
        //from: whatsappNumber
        contentSid: templateSid,
        from: 'MG267f4c8d473e514d2ed7f6fa3745740c',
        contentVariables: JSON.stringify(variables),
        to: `whatsapp:${to}`,
    })
    .then(message => {
        console.error('WhatsApp message sent. messageId: ', message.sid);
    })
    .catch(error => {
        console.error('Error sending WhatsApp message: ', error);
    });
}

function sendWhatsAppClientAppointmentConfirmation(to: string, variables: any) {
    sendWhatsAppMessage(to, 'HXf22d506e4ba0b228512a383deab636d0', variables);
}

function sendWhatsAppServiceProviderAppointmentConfirmation(to: string, variables: any) {
    sendWhatsAppMessage(to, 'HX158cf4538b4566b87650380b17ab4624', variables);
}

function sendWhatsAppClientAppointmentChange(to: string, variables: any) {
    sendWhatsAppMessage(to, 'HXa360c9a8c58df1202c4bd9a922f504e6', variables);
}

function sendWhatsAppServiceProviderAppointmentChange(to: string, variables: any) {
    sendWhatsAppMessage(to, 'HXbb2f6dec4ece99db49faf4773e9d1a7d', variables);
}

function sendWhatsAppClientAppointmentCancellation(to: string, variables: any, cancelledByClient: boolean) {
    sendWhatsAppMessage(to, cancelledByClient ? 'HX0b4e55de4d5d05533b2ed0047291450d' : 'HX699703b4a3acebcb7cbed9c317beeacc', variables);
}

function sendWhatsAppServiceProviderAppointmentCancellation(to: string, variables: any, cancelledByClient: boolean) {
    sendWhatsAppMessage(to, cancelledByClient ? 'HX12114ac224836c66a58d0bb6311dc8a3' : 'HX53bfe8fa16c7a3f119f7eaa722b60f8d', variables);
}

function sendWhatsAppClientAppointmentReminder(to: string, variables: any) {
    sendWhatsAppMessage(to, 'HX2ebb69b50f76877d3a243a605654c402', variables);
}

//stripe
async function createSetupIntent(customerId: any) {
  try {
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
    });

    console.log("SetupIntent created:", setupIntent);
    return setupIntent;
  } catch (error) {
    console.error("Erro creating SetupIntent:", error);
  }
}

async function onPaymentMethodAttached(paymentMethod: any, res: any, ) {
  try {
      // Lista o atual método de pagamento do cliente
      const existingPaymentMethods = await stripe.paymentMethods.list({
          customer: paymentMethod.customer,
          type: 'card',
      });

      // Verifica e desvincula o método de pagamento existente, se houver algum além do novo
      for (const pm of existingPaymentMethods.data) {
          if (pm.id !== paymentMethod.id) {
              await stripe.paymentMethods.detach(pm.id);
              console.log(`Detached existing payment method ${pm.id} from customer ${paymentMethod.customer}`);
          }
      }

      // Define o novo método de pagamento como padrão
      await stripe.customers.update(paymentMethod.customer, {
          invoice_settings: {
              default_payment_method: paymentMethod.id,
          },
      });

      console.log(`New payment method ${paymentMethod.id} set as default for customer ${paymentMethod.customer}`);
      res.json({received: true, message: 'New payment method set as default and existing one detached'});
  } catch (error) {
      console.error(`Error processing payment_method.attached event: ${error}`);
      res.status(500).json({received: false, error: error});
  }
}

async function createSubscriptionForCustomer(customerId: any, promotionCode: any, res: any, ) {
  if(customerId){
    let subscriptionOptions : any = {
      customer: customerId,
      items: [{ price: premiumSubscriptionPrice }],
    };

    if (promotionCode) {
      try {
        const promotionCodeObject = await stripe.promotionCodes.list({
          code: promotionCode,
        });

        if (promotionCodeObject.data.length > 0) {
          const validPromotionCode = promotionCodeObject.data[0];
          subscriptionOptions["promotion_code"] = validPromotionCode.id;
        } else {
          console.log('Código de promoção não encontrado.');
        }
      } catch (e) {
        console.error('Erro ao recuperar o código de promoção:', e);
        res.json({
          status: "ERROR: PROVIDED PROMOTION_CODE NOT VALID ( promotionCode = " + promotionCode + " )",
        });
        return;
      }
    }
    try{

      // Cria a assinatura com o código de promoção
      //const subscription = await stripe.subscriptions.create(subscriptionOptions);
      await stripe.subscriptions.create(subscriptionOptions);

      console.log('Assinatura criada com sucesso.');

      //await admin.firestore().collection('users').doc(customerId).update({
      //  subscription_id: subscription.id,
      //});

      res.json({
        status: "SUCCESS",
      });
    }
    catch(e){
      res.json({
        status: "ERROR: IN STRIPE ( " + e + " )",
      });
    }
  }
  else{
    res.json({
      status: "ERROR: PROVIDED DATA NOT VALID ( customerId = " + customerId + " )",
    });
  }
}

//firebase
async function addUserAsClient(clientId: string, serviceProviderId: string) {

    const clientRef = admin.firestore().collection('users').doc(clientId);
    const clientDoc = await clientRef.get();

    if (!clientDoc.exists) {
        console.log("Document not found.");
        return;
    }

    const clientData = clientDoc.data();
    if (!clientData) {
      console.log('Service provider data is undefined');
      return null;
    }

    // Exclude specific fields and prepare the data to be set in the clients subcollection
    // eslint-disable-next-line camelcase
    const { blocked_periods, blocked_clients_ids, availability_map, ...clientDataToCopy } = clientData;

    const newClientRef = admin.firestore().collection('users').doc(serviceProviderId).collection('clients').doc(clientId);
    console.log(`User ${clientId} added as client of ${serviceProviderId}.`);
    return newClientRef.set(clientDataToCopy);

}

exports.syncUserInfoAcrossClients = functions.firestore
    .document('users/{userId}')
    .onWrite(async (change, context) => {
        // ID of the user that was modified
        const userId = context.params.userId;

        // Data of the user after the modification
        const newUserData = change.after.exists ? change.after.data() : null;
        // If the user document was deleted, there's no need to synchronize
        if (!newUserData) {
            console.log(`User ${userId} deleted. No synchronization action needed.`);
            return null;
        }

        // Creating a copy of newUserData excluding specific fields
        // eslint-disable-next-line camelcase
        const { blocked_periods, blocked_clients_ids, availability_map, ...userDataToSync } = newUserData;

        // Performing a group query across all 'clients' subcollections for documents where 'user_id' matches the modified user's ID
        const clientDocs = await admin.firestore().collectionGroup('clients').where('user_id', '==', userId).get();

        // Updating each found document with the new user information, excluding specific fields
        const updates = clientDocs.docs.map(doc => {
            console.log(`Updating information for client with user_id ${userId} in path ${doc.ref.path}, excluding blocked_periods, blocked_clients_ids, and availability_map.`);
            return doc.ref.set(userDataToSync);
        });

        // Waiting for all updates to complete
        await Promise.all(updates);

        console.log(`Synchronization completed for modified user ${userId}, excluding specific fields.`);
        return null;
    });

//firebase functions:config:set twilio.sid="ACc547b8353217267e0a3aa4aa1780613f" twilio.token="1bbb0f2dd31e72ed2e2ddc17fd7c31e1"
//firebase functions:config:set twilio.testsid="AC7c0772c9929d59333dcc2b88156fd784" twilio.testtoken="0ddc873f356b488c9ed939901252847e"

exports.sendNotificationsOnAppointmentCreate = functions.firestore
  .document('appointments_details/{appointmentId}')
  .onCreate(async (snap: DocumentSnapshot, context: functions.EventContext) => {
    const appointmentDetails = snap.data();

    if (!appointmentDetails) {
      console.log('Appointment details are undefined');
      return null;
    }

    // Get the user ID and service provider name from the created document
    const userId = appointmentDetails.user_id;
    const serviceProviderId = appointmentDetails.service_provider_user_id;

    if (!userId) {
      console.log('User ID is undefined');
      //return null;
    }

    if (!serviceProviderId) {
      console.log('Service Provider ID is undefined');
      return null;
    }

    // References to the users and service providers collections
    let userRef;
    if(userId){userRef = admin.firestore().collection('users').doc(userId);}
    const serviceProviderRef = admin.firestore().collection('users').doc(serviceProviderId);

    // Get the user and service provider documents to retrieve emails
    const serviceProviderDoc = await serviceProviderRef.get();

    if (!serviceProviderDoc.exists) {
        console.log('No service provider found with the given ID');
        return null;
    }

    const serviceProviderData = serviceProviderDoc.data();
    if (!serviceProviderData) {
      console.log('Service provider data is undefined');
      return null;
    }

    const serviceProviderEmail = serviceProviderData.email;
    if (!serviceProviderEmail) {
      console.log('Service provider email is undefined');
      return null;
    }

    let userData;
    let userEmail;
    if(userRef){
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            console.log('No user found with the given ID');
            return null;
        }

        userData = userDoc.data();
        if (!userData) {
          console.log('User data is undefined');
          return null;
        }

        userEmail = userData.email;
        if (!userEmail) {
          console.log('User email is undefined');
          return null;
        }
    }



    const serviceName = appointmentDetails.service_name; // The service name
    const userName = appointmentDetails.user_name; // The client name
    const serviceProviderName = appointmentDetails.service_provider_name; // The service provider name
    const dateString = appointmentDetails.from;
    if (!dateString) {
      console.log('Appointment "from" field is undefined');
      return null;
    }

    const [datePart, timePart] = dateString.split(' ');
    const dateTimeText = `${formatDateStringToMessage(datePart)} às ${timePart}`;

    if(userId){addUserAsClient(userId, serviceProviderId);}

    const serviceProviderPhone = serviceProviderData.phone;
    console.log('Service provider phone = ', serviceProviderPhone);
    let userPhone;
    if(userData){
        userPhone = userData.phone;
        console.log('Client phone = ', userPhone);

        sendEmail(
          userEmail,
         `Confirmação do Agendamento: ${serviceName} com ${serviceProviderName} em ${dateTimeText}`,
         `Olá! Seu agendamento para ${serviceName} com ${serviceProviderName} foi confirmado com sucesso.\n\nDetalhes do seu Agendamento:\n- Serviço: ${serviceName}\n- Prestador de Serviço: ${serviceProviderName}\n- Data e Hora: ${dateTimeText}\n\nAgradecemos por escolher nossos serviços. Lembre-se de verificar qualquer atualização sobre seu agendamento no site. Caso tenha dúvidas ou precise alterar seu horário, estamos à disposição.\n\nAtenciosamente,\nEquipe Booker`,
        );

        if (userPhone) {
          //sendWhatsAppMessage(userPhone, `Olá! Seu agendamento para ${serviceName} com ${serviceProviderName} foi confirmado com sucesso.\n\nDetalhes do seu Agendamento:\n- Serviço: ${serviceName}\n- Prestador de Serviço: ${serviceProviderName}\n- Data e Hora: ${dateTimeText}\n\nAgradecemos por escolher nossos serviços. Lembre-se de verificar qualquer atualização sobre seu agendamento no site. Caso tenha dúvidas ou precise alterar seu horário, estamos à disposição`);
          const variables = {
              serviceName: serviceName,
              serviceProviderName: serviceProviderName,
              dateTimeText: dateTimeText,
          };
          sendWhatsAppClientAppointmentConfirmation(userPhone, variables);
        }
        else{
          console.log('Client phone is undefined');
        }
    }

    sendEmail(
        serviceProviderEmail,
        `Novo Agendamento: ${serviceName} para o dia ${dateTimeText}`,
        `Olá! Você tem um novo agendamento de serviço.\n\nDetalhes do Agendamento:\n- Cliente: ${userName}\n- Serviço: ${serviceName}\n- Data e Hora: ${dateTimeText}\n\nEstamos à disposição para qualquer suporte necessário.\n\nAtenciosamente,\nEquipe Booker`,
    );

    if (serviceProviderPhone) {
        //sendWhatsAppMessage(serviceProviderPhone, `Olá! Você tem um novo agendamento de serviço.\n\nDetalhes do Agendamento:\n- Cliente: ${userName}\n- Serviço: ${serviceName}\n- Data e Hora: ${dateTimeText}\n\nEstamos à disposição para qualquer suporte necessário.\n\nAtenciosamente,\nEquipe Booker`);
        const variables = {
            serviceName: serviceName,
            userName: userName,
            dateTimeText: dateTimeText,
        };
        sendWhatsAppServiceProviderAppointmentConfirmation(serviceProviderPhone, variables);
    }
    else{
        console.log('Service provider phone is undefined');
    }

    return;
});

exports.sendNotificationsOnAppointmentTimeChange = functions.firestore
    .document('appointments_details/{appointmentId}')
    .onUpdate(async (change, context) => {
       // Getting the before and after snapshot
       const beforeData = change.before.data();
       const afterData = change.after.data();

       // Check if the 'from' field (appointment time) was changed
       if (beforeData.from === afterData.from) {
           console.log('Appointment time has not changed');
           return null;
       }

       //const oldDateTimeText = formatDateStringToMessage(beforeData.from.split(' ')[0]) + ' às ' + beforeData.from.split(' ')[1];
       //const newDateTimeText = formatDateStringToMessage(afterData.from.split(' ')[0]) + ' às ' + afterData.from.split(' ')[1];

       const appointmentDetails = afterData;

       if (!appointmentDetails) {
         console.log('Appointment details are undefined');
         return null;
       }

       // Get the user ID and service provider name from the created document
       const userId = appointmentDetails.user_id;
       const serviceProviderId = appointmentDetails.service_provider_user_id;

       if (!userId) {
         console.log('User ID is undefined');
         //return null;
       }

       if (!serviceProviderId) {
         console.log('Service Provider ID is undefined');
         return null;
       }

       // References to the users and service providers collections
       let userRef;
       if(userId){userRef = admin.firestore().collection('users').doc(userId);}
       const serviceProviderRef = admin.firestore().collection('users').doc(serviceProviderId);

       // Get the user and service provider documents to retrieve emails
       const serviceProviderDoc = await serviceProviderRef.get();

       if (!serviceProviderDoc.exists) {
           console.log('No service provider found with the given ID');
           return null;
       }

       const serviceProviderData = serviceProviderDoc.data();
       if (!serviceProviderData) {
         console.log('Service provider data is undefined');
         return null;
       }

       const serviceProviderEmail = serviceProviderData.email;
       if (!serviceProviderEmail) {
         console.log('Service provider email is undefined');
         return null;
       }

       let userData;
       let userEmail;
       if(userRef){
           const userDoc = await userRef.get();

           if (!userDoc.exists) {
               console.log('No user found with the given ID');
               return null;
           }

           userData = userDoc.data();
           if (!userData) {
             console.log('User data is undefined');
             return null;
           }

           userEmail = userData.email;
           if (!userEmail) {
             console.log('User email is undefined');
             return null;
           }
       }

       const serviceName = appointmentDetails.service_name; // The service name
       const userName = appointmentDetails.user_name; // The client name
       const serviceProviderName = appointmentDetails.service_provider_name; // The service provider name
       const dateString = appointmentDetails.from;
       if (!dateString) {
         console.log('Appointment "from" field is undefined');
         return null;
       }

       const [datePart, timePart] = dateString.split(' ');
       const dateTimeText = `${formatDateStringToMessage(datePart)} às ${timePart}`;

       if(userId){addUserAsClient(userId, serviceProviderId);}

       const serviceProviderPhone = serviceProviderData.phone;
       console.log('Service provider phone = ', serviceProviderPhone);
       let userPhone;
       if(userData){
           userPhone = userData.phone;
           console.log('Client phone = ', userPhone);

           sendEmail(
             userEmail,
            `Alteração do Agendamento: ${serviceName} com ${serviceProviderName} em ${dateTimeText}`,
            `Olá! Seu agendamento para ${serviceName} com ${serviceProviderName} foi alterado.\n\nNovo horário do Agendamento: ${dateTimeText}\n\nAgradecemos por escolher nossos serviços. Caso tenha dúvidas ou precise alterar seu horário, estamos à disposição.\n\nAtenciosamente,\nEquipe Booker`,
           );

           if (userPhone) {
             //sendWhatsAppMessage(userPhone, `Olá! Seu agendamento para ${serviceName} com ${serviceProviderName} foi confirmado com sucesso.\n\nDetalhes do seu Agendamento:\n- Serviço: ${serviceName}\n- Prestador de Serviço: ${serviceProviderName}\n- Data e Hora: ${dateTimeText}\n\nAgradecemos por escolher nossos serviços. Lembre-se de verificar qualquer atualização sobre seu agendamento no site. Caso tenha dúvidas ou precise alterar seu horário, estamos à disposição`);
             const variables = {
                 serviceName: serviceName,
                 serviceProviderName: serviceProviderName,
                 dateTimeText: dateTimeText,
             };
             sendWhatsAppClientAppointmentChange(userPhone, variables);
           }
           else{
             console.log('Client phone is undefined');
           }
       }

       sendEmail(
           serviceProviderEmail,
           `Alteração do Agendamento: ${serviceName} para o dia ${dateTimeText}`,
           `Olá! Você alterou um agendamento de serviço.\n\nDetalhes atualizados do Agendamento:\n- Cliente: ${userName}\n- Serviço: ${serviceName}\n- Data e Hora: ${dateTimeText}\n\nEstamos à disposição para qualquer suporte necessário.\n\nAtenciosamente,\nEquipe Booker`,
       );

       if (serviceProviderPhone) {
           //sendWhatsAppMessage(serviceProviderPhone, `Olá! Você tem um novo agendamento de serviço.\n\nDetalhes do Agendamento:\n- Cliente: ${userName}\n- Serviço: ${serviceName}\n- Data e Hora: ${dateTimeText}\n\nEstamos à disposição para qualquer suporte necessário.\n\nAtenciosamente,\nEquipe Booker`);
           const variables = {
               serviceName: serviceName,
               userName: userName,
               dateTimeText: dateTimeText,
           };
           sendWhatsAppServiceProviderAppointmentChange(serviceProviderPhone, variables);
       }
       else{
           console.log('Service provider phone is undefined');
       }

        return;
    });

exports.sendCancellationNotifications = functions.firestore
  .document('appointments_details/{appointmentId}')
  .onUpdate((change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if the status has changed to 'canceled'
    if (beforeData.status !== 'canceled' && afterData.status === 'canceled') {
      // Retrieve user and service provider details
      const userId = afterData.user_id;
      const serviceProviderId = afterData.service_provider_user_id;

      // References to the users and service providers collections
      const userRef = admin.firestore().collection('users').doc(userId);
      const serviceProviderRef = admin.firestore().collection('users').doc(serviceProviderId);

      // Get the user and service provider documents to retrieve emails
      return userRef.get().then((userDoc) => {
        if (!userDoc.exists) {
          console.log('No user found with the given ID');
          return null;
        }

        const userData = userDoc.data();
        if (!userData) {
          console.log('User data is undefined');
          return null;
        }

        const userEmail = userData.email;
        if (!userEmail) {
          console.log('User email is undefined');
          return null;
        }

        return serviceProviderRef.get().then((serviceProviderDoc) => {
          if (!serviceProviderDoc.exists) {
            console.log('No service provider found with the given ID');
            return null;
          }

          const serviceProviderData = serviceProviderDoc.data();
          if (!serviceProviderData) {
            console.log('Service provider data is undefined');
            return null;
          }

          const serviceProviderEmail = serviceProviderData.email;
          if (!serviceProviderEmail) {
            console.log('Service provider email is undefined');
            return null;
          }

          const serviceName = afterData.service_name;
          const userName = userData.name;
          const userPhone = userData.phone;
          const serviceProviderName = serviceProviderData.name;
          const serviceProviderPhone = serviceProviderData.phone;
          const dateString = afterData.from;
          const cancellationMessage = afterData.cancel_message; // Default message if none provided
          const cancelledByUser = afterData.canceled_by === 'client';

          const userCancellationMessageText = cancellationMessage ? `\n\nMotivo do cancelamento:\n${cancellationMessage}` : '';
          const serviceProviderCancellationMessageText = cancellationMessage ? `\n\nMotivo do cancelamento informado ao cliente:\n${cancellationMessage}` : '\n\nMotivo do cancelamento informado ao cliente:\nVocê não informou o motivo do cancelamento.';

          // Prepare email text
          const [datePart, timePart] = dateString.split(' ');
          const dateTimeText = `${formatDateStringToMessage(datePart)} às ${timePart}`;
          const userCancellationText = `Olá ${userName},\n\nLamentamos informar que seu agendamento para ${serviceName} no dia ${dateTimeText} foi cancelado por ${serviceProviderName}.${userCancellationMessageText}\n\nPedimos desculpas por qualquer inconveniente. Para reagendar ou para mais informações, por favor, entre em contato conosco.\n\nAtenciosamente,\nEquipe Booker`;
          const userNotificationText = `Olá ${userName},\n\nSeu agendamento para ${serviceName} no dia ${dateTimeText} com ${serviceProviderName} foi cancelado conforme seu pedido.\n\nSe você tiver alguma dúvida ou quiser reagendar, por favor, entre em contato conosco.\n\nAtenciosamente,\nEquipe Booker`;
          const serviceProviderCancellationText = `Olá ${serviceProviderName},\n\nO agendamento de ${serviceName} no dia ${dateTimeText} foi cancelado pelo cliente ${userName}.\n\nPor favor, atualize sua agenda e entre em contato conosco se tiver alguma dúvida.\n\nAtenciosamente,\nEquipe Booker`;
          const serviceProviderNotificationText = `Olá ${serviceProviderName},\n\nO agendamento de ${serviceName} no dia ${dateTimeText} com o cliente ${userName} foi cancelado conforme seu pedido.${serviceProviderCancellationMessageText}\n\nSe você tiver alguma dúvida, entre em contato conosco.\n\nAtenciosamente,\nEquipe Booker`;

          const variables = {
              userName: userName,
              serviceName: serviceName,
              serviceProviderName: serviceProviderName,
              dateTimeText: dateTimeText,
              //userCancellationMessageText: userCancellationMessageText,
              //serviceProviderCancellationMessageText: serviceProviderCancellationMessageText,
          };

          return sendEmail(
            userEmail,
            cancelledByUser ? `Cancelamento confirmado` : `Agendamento cancelado`,
            cancelledByUser ? userNotificationText : userCancellationText,
          ).then(() => {

            if (userPhone) {
                sendWhatsAppClientAppointmentCancellation(userPhone, variables, cancelledByUser);
            }

            return sendEmail(
                serviceProviderEmail,
                cancelledByUser ? `Agendamento cancelado de ${serviceName} para o dia ${dateTimeText}` : `Cancelamento de ${serviceName} para o dia ${dateTimeText} confirmado`,
                cancelledByUser ? serviceProviderCancellationText : serviceProviderNotificationText,
            ).then(() => {
                if (serviceProviderPhone) {
                    sendWhatsAppServiceProviderAppointmentCancellation(serviceProviderPhone, variables, cancelledByUser);
                }
            });
          });

        });
      }).then((info: nodemailer.SentMessageInfo) => {
        console.log('Email sent: ' + info.response);
      }).catch((error: Error) => {
        console.log(error);
      });
    }

    return null;
  });

exports.createStripeCustomer = functions.firestore
    .document("/users/{userId}")
    .onUpdate((change, context) => {
      const beforeUserData = change.before.data();
      const afterUserData = change.after.data();


      //to only create stripe customers if they become a service provider.
      if(beforeUserData.is_service_provider === false && afterUserData.is_service_provider === true) {

        const customerParams = {
               "id": context.params.userId,
               "email": afterUserData.email,
             };

        return stripe.customers.create(customerParams, function(err: any, customer: any) {
           if (err) {
             console.log("err" + err);
           }
           if (customer) {
             console.log("customer created");
             console.log(customer);
           } else {
             console.log("unknown error");
           }
        });
      }
      return null;
});

exports.checkAndSendReminders = functions.pubsub.schedule('every 10 minutes').onRun(async (context) => {
    const now = new Date();
    now.setTime(now.getTime() - (3 * 60 * 60 * 1000));//o -3 horas é para adaptar para o horários brasileiro, caso o app seja expandido, terá que ser adpatdado
    const oneHourLater = new Date(now.getTime() + (60 * 60 * 1000));

    // Formate as datas para strings no formato 'YYYY-MM-DD HH:MM'
    const nowString = formatDateToString(now);
    const oneHourLaterString = formatDateToString(oneHourLater);

    console.log('nowString = ' + nowString);
    console.log('oneHourLaterString = ' + oneHourLaterString);

    const appointmentsRef = admin.firestore().collection('appointments_details');
    const querySnapshot = await appointmentsRef
        .where('from', '>=', nowString)
        .where('from', '<=', oneHourLaterString)
        .where('reminder_sent', '==', false)
        .get();

    if (querySnapshot.empty) {
        console.log('No appointments to send reminders for');
        return null;
    }

    const sendReminderPromises: Promise<void | WriteResult>[] = [];

    for (const doc of querySnapshot.docs) {
      const appointmentDetails = doc.data();
      const userId = appointmentDetails.user_id;
      //const serviceProviderId = appointmentDetails.service_provider_user_id;

      // Obtenha referências para os documentos dos usuários e prestadores de serviço
      const userRef = admin.firestore().collection('users').doc(userId);
      //const serviceProviderRef = admin.firestore().collection('users').doc(serviceProviderId);


      return userRef.get().then((userDoc: DocumentSnapshot) => {
        if (!userDoc.exists) {
            console.log('No user found with the given ID');
            return null;
        }

        const userData = userDoc.data();
        if (!userData) {
          console.log('User data is undefined');
          return null;
        }

        const userEmail = userData.email;
        if (!userEmail) {
          console.log('User email is undefined');
          return null;
        }

        const userPhone = userData.phone;
        const serviceName = appointmentDetails.service_name; // The service name
        const userName = appointmentDetails.user_name; // The client name
        const serviceProviderName = appointmentDetails.service_provider_name; // The service provider name
        const dateString = appointmentDetails.from;
        if (!dateString) {
          console.log('Appointment "from" field is undefined');
          return null;
        }
        const [datePart, timePart] = dateString.split(' ');
        const dateTimeText = `${formatDateStringToMessage(datePart)} às ${timePart}`;

        const emailSubject = `Lembrete de Agendamento: ${serviceName} com ${serviceProviderName} em ${dateTimeText}`;
        const emailBody = `Olá ${userName},\n\nEste é um lembrete do seu agendamento para ${serviceName} com ${serviceProviderName} em ${dateTimeText}.\n\nAtenciosamente,\nEquipe Booker`;

        return sendReminderPromises.push(
          sendEmail(userEmail, emailSubject, emailBody).then(() => {
              if (userPhone) {
                const variables = {
                    userName: userName,
                    serviceName: serviceName,
                    serviceProviderName: serviceProviderName,
                    dateTimeText: dateTimeText,
                };
                sendWhatsAppClientAppointmentReminder(userPhone, variables);
              }
              // Marque o agendamento como notificado
              return doc.ref.update({reminder_sent: true});

          })
        );
      });
    }

    // Aguarda todas as promessas de envio de e-mail serem resolvidas
    return Promise.all(sendReminderPromises).then(() => {
        console.log('All reminders sent');
    }).catch((error) => {
        console.log('Error sending reminders:', error);
    });
});

exports.createSetupIntent = functions.https.onRequest(async (req, res) => {
  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    //const customerId = req.body?.customer_id;
    console.log("uid = " + uid);

    const customerId = uid;
    const setupIntent = await createSetupIntent(customerId);

    res.status(200).json({
      clientSecret: setupIntent.client_secret,
    });

  });

});

exports.getCustomerPaymentMethods = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

      const {uid, error} = await verifyToken(req);

      console.log("uid = ", uid);
      console.log("error = ", error);

      if (error || uid == null) {
        res.status(401).send(error);
        return;
      }


      //const customerId = req.body?.customer_id;
      const customerId = uid;

      // List the customer's payment methods
      if(customerId){
        try{
          const paymentMethods = await stripe.paymentMethods.list({
            //customer: customer.data[0].id,
            customer: customerId,
            type: "card",
          });

          console.log("paymentMethods = ", paymentMethods);

          res.json({
            status: "SUCCESS",
            payment_methods: paymentMethods.data,
          });
        }
        catch(e){
          res.json({
            status: "ERROR: IN STRIPE ( " + e + " )",
          });
        }
      }
      else{
        res.json({
          status: "ERROR: DATA NOT VALID ( " + customerId + " )",
        });
      }

  });

});

exports.createSubscriptionForCustomer = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    //const customerId = req.body?.customer_id;
    const customerId = uid;
    const promotionCode = req.body?.promotion_code || null;

    console.log("uid = " + uid);

    createSubscriptionForCustomer(customerId, promotionCode, res);

  });

});

exports.getCouponFromPromotionCode = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    const promotionCode = req.body?.promotion_code || null;

    if (!promotionCode) {
      res.json({
        status: "ERROR: NO PROMOTION CODE PROVIDED",
      });
      return;
    }
     try {
      const promotionCodeObject = await stripe.promotionCodes.list({
        code: promotionCode,
      });

      if (promotionCodeObject.data.length === 0) {
        res.json({
          status: "ERROR: PROMOTION NOT FOUND",
        });
      } else {
        const promoCode = promotionCodeObject.data[0];
        if (promoCode.active) {
          // O código promocional está ativo e, portanto, válido
          // Aqui, recuperamos os detalhes do cupom usando o ID do cupom associado ao código promocional
          const coupon = await stripe.coupons.retrieve(promoCode.coupon.id);
          // Retorna o cupom
          res.json(coupon);
        } else {
          // O código promocional não está ativo, o que implica que pode estar expirado ou desativado por outros motivos
          res.json({
            status: "ERROR: PROMOTION CODE NOT VALID",
          });
        }
      }
     } catch (error) {
       console.error('Erro ao verificar o código promocional:', error);
       res.json({
         status: "ERROR: IN PROMOTION CODE VERIFICATION",
       });
     }
  });

});

exports.getCustomerSubscription = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    const customerId = uid;
    try {
     const subscriptions = await stripe.subscriptions.list({
       customer: customerId,
       status: "all",
       limit: 1, // Obtém apenas a mais recente
     });

    if (subscriptions.data.length > 0) {
      res.status(200).json(subscriptions.data[0]);
    } else {
      res.status(404).json({
        status: "ERROR: SUBSCRIPTION NOT FOUND",
      });
    }
   } catch (error) {
     console.error('Stripe Error:', error);
     res.status(500).json({
       status: "ERROR: RETRIEVING SUBSCRIPTION",
     });
   }
  });

});

exports.cancelCustomerSubscription = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    const customerId = uid;
    try {
     const subscriptions = await stripe.subscriptions.list({
       customer: customerId,
       limit: 1, // Obtém apenas a mais recente
       status: 'active',
     });

    if (subscriptions.data.length > 0) {
      const subscription = subscriptions.data[0];

      //await stripe.subscriptions.cancel(subscription.id); // para cancelamento imediato
      await stripe.subscriptions.update(subscription.id, {
        cancel_at_period_end: true,
      });

      res.status(200).json({status: "SUCCESS: SUBSCRIPTION CANCELED SUCCESSFULLY",});
    } else {
      res.status(404).json({
        status: "ERROR: SUBSCRIPTION NOT FOUND",
      });
    }
   } catch (error) {
     console.error('Stripe Error:', error);
     res.status(500).json({
       status: "ERROR: CANCELLING SUBSCRIPTION",
     });
   }
  });

});

// Only useful if the subscription is canceled but still valid
exports.reactivateCustomerSubscription = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    const customerId = uid;
    try {
     const subscriptions = await stripe.subscriptions.list({
       customer: customerId,
       limit: 1, // Obtém apenas a mais recente
       status: 'active',
     });

    if (subscriptions.data.length > 0) {
      const subscription = subscriptions.data[0];

      // Cancela o cancelamento programado da assinatura
      await stripe.subscriptions.update(subscription.id, {
        cancel_at_period_end: false,
      });

      res.status(200).json({status: "SUCCESS: SUBSCRIPTION REACTIVATED SUCCESSFULLY",});
    } else {
      res.status(404).json({
        status: "ERROR: SUBSCRIPTION NOT FOUND",
      });
    }
   } catch (error) {
     console.error('Stripe Error:', error);
     res.status(500).json({
       status: "ERROR: REACTIVATING SUBSCRIPTION",
     });
   }
  });

});

app.post('/', (req: any, res: any) => {
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    } catch (error) {
        console.error('Webhook Error:', error);
        return res.status(400).send(`Webhook Error: ${error}`);
    }

    // Verifica o tipo do evento
    if (event.type === 'payment_method.attached') {
        console.log('stripe-webhook event: payment_method.attached');
        const paymentMethod = event.data.object;
        onPaymentMethodAttached(paymentMethod, res);
    }
    else {
        // Responde ao Stripe que o evento foi recebido, mas não tratado
        res.json({received: true, message: 'Event received but not handled'});
    }
});

exports.stripeWebhook = functions.https.onRequest(app);

/*
async function detachPaymentMethodFromCustomer(customerId: any, paymentMethodId: any, res: any, ) {
  if(customerId && paymentMethodId){
    try{
      await stripe.paymentMethods.detach(
        paymentMethodId,
      );
      res.json({
        status: "SUCCESS",
      });
    }
    catch(e){
      res.json({
        status: "ERROR: IN STRIPE ( " + e + " )",
      });
    }
  }
  else{
    res.json({
      status: "ERROR: PROVIDED DATA NOT VALID ( customerId = " + customerId + ", paymentMethodId = " + paymentMethodId + " )",
    });
  }
}

exports.detachPaymentMethodFromCustomer = functions.https.onRequest(async (req, res) => {

  corsMiddleware(req, res, async () => {

    const {uid, error} = await verifyToken(req);

    if (error || uid == null) {
      res.status(401).send(error);
      return;
    }

    //const customerId = req.body?.customer_id;
    const customerId = uid;
    const paymentMethodId = req.body?.payment_method_id;

    console.log("uid = " + uid);
    console.log("customerId = " + customerId);
    console.log("paymentMethodId = " + paymentMethodId);

    detachPaymentMethodFromCustomer(customerId, paymentMethodId, res);

  });

});


exports.onSubscriptionCreated = functions.firestore
  .document('subscriptions/{subscriptionId}')
  .onCreate(async (snap: DocumentSnapshot, context: functions.EventContext) => {
      const promises: any = [];

      const subscriptionData = snap.data();

      if (!subscriptionData) {
        console.log('subscription is undefined');
        return null;
      }

      const subscriptionId = subscriptionData.id;
      const userId = subscriptionData.user_id;
      //const paymentMethodId = subscriptionData.payment_method_id;
      const discountCodeId = subscriptionData.discount_code_id;


      if (!userId) {
        console.log('User ID is undefined');
        return null;
      }

      //if (!paymentMethodId) {
      //  console.log('Payment Method ID is undefined');
      //  return null;
      //}

      if (discountCodeId) {
        const discountCodeDoc = await admin.firestore().collection('discount_codes').doc(discountCodeId).get();
        if (discountCodeDoc) {
            const discountCodeData = discountCodeDoc.data();
            if (discountCodeData) {
                const discountCodeIsValid = discountCodeData.status === "valid";
                if(discountCodeIsValid){
                    const now = new Date();
                    const creationDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
                    const nextRenewalDate = new Date(creationDate);
                    nextRenewalDate.setMonth(creationDate.getMonth() + 1);

                    // Formata as datas como strings no formato "YYYY-MM-DD HH:MM"
                    const creationDateString = formatDateToString(creationDate);
                    const nextRenewalDateString = formatDateToString(nextRenewalDate);



                    const p0 = admin.firestore().collection('subscriptions').doc(subscriptionId).update({
                        status: "valid",
                        creation_date: creationDateString,
                        next_renewal_date: nextRenewalDateString,
                    });
                    promises.push(p0);

                    // References to the users collections
                    const userRef = admin.firestore().collection('users').doc(userId);
                    //update user subscription level
                    const p1 = userRef.update({subscription_id: subscriptionId,});
                    promises.push(p1);

                    const salesRepId = discountCodeData.sales_rep_id;
                    if (salesRepId) {
                        const p2 = admin.firestore().collection('sales_reps').doc(salesRepId).update({
                           number_of_clients: admin.firestore.FieldValue.increment(1),
                        });
                        promises.push(p2);
                    }
                }
            }
        }
      }

      return Promise.all(promises);
  });


  exports.renewSubscriptions = functions.pubsub.schedule('0 0 * * *').timeZone('America/Sao_Paulo').onRun(async (context) => {
    const now = new Date();
    now.setTime(now.getTime() - (3 * 60 * 60 * 1000));//o -3 horas é para adaptar para o horários brasileiro, caso o app seja expandido, terá que ser adpatdado
    // Formate as datas para strings no formato 'YYYY-MM-DD HH:MM'
    const nowString = formatDateToString(now);
    console.log('nowString = ' + nowString);

    const appointmentsRef = admin.firestore().collection('subscriptions');
    const querySnapshot = await appointmentsRef
        .where('next_renewal_date', '==', nowString)
        .get();

    if (querySnapshot.empty) {
        console.log('No subscriptions to renew');
        return null;
    }

    const renewSubscriptionsPromises: Promise<void | WriteResult>[] = [];

    for (const doc of querySnapshot.docs) {
      //const subscriptionData = doc.data();
      //const paymentMethodId = subscriptionData.payment_method_id;

      // Obtenha referências para os documentos dos usuários e prestadores de serviço
      // Do Stripe Payment
      const paymentDone = true;

      if(!paymentDone){
        const p = doc.ref.update({status: "suspended"});
        renewSubscriptionsPromises.push(p);
      }
    }

    return Promise.all(renewSubscriptionsPromises);
  });

*/






