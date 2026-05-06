/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util; // Assuming you have a 'util' package

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    // SMTP Configuration for Gmail
    // Ensure these are correct and SMTP_PASSWORD is your 16-character App Password
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587"; // For TLS
    private static final String SMTP_USER = "dulanga1000@gmail.com"; // Your sending Gmail address
    private static final String SMTP_PASSWORD = "fdaycthsjmtjpdbq"; // YOUR 16-CHARACTER APP PASSWORD
    private static final String EMAIL_FROM_ADDRESS = "dulanga1000@gmail.com"; // Displayed From address
    private static final String EMAIL_FROM_NAME = "Swift POS Store"; // Displayed From name

    /**
     * Sends an HTML email.
     * @param recipientEmail The email address of the recipient.
     * @param subject The subject of the email.
     * @param htmlContent The HTML content of the email body.
     * @return true if the email was sent successfully, false otherwise.
     */
    public static boolean sendHtmlEmail(String recipientEmail, String subject, String htmlContent) {
        LOGGER.log(Level.INFO, "Attempting to send email to: {0} with subject: {1}", new Object[]{recipientEmail, subject});

        // Corrected placeholder check
        final String PLACEHOLDER_PASSWORD = "PASTE_YOUR_16_CHARACTER_APP_PASSWORD_HERE"; // Standard placeholder

        if (SMTP_PASSWORD == null || PLACEHOLDER_PASSWORD.equals(SMTP_PASSWORD) || SMTP_PASSWORD.trim().isEmpty()) {
             LOGGER.severe("CRITICAL EmailUtil ERROR: SMTP_PASSWORD is not configured or is a placeholder. Please update it in EmailUtil.java.");
             return false;
        }
        if (recipientEmail == null || recipientEmail.trim().isEmpty() || !recipientEmail.contains("@")) {
            LOGGER.log(Level.WARNING, "Invalid recipient email address: {0}", recipientEmail);
            return false;
        }


        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        // props.put("mail.debug", "true"); // Uncomment for verbose JavaMail logs in server console

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
            }
        });
        // session.setDebug(true); // Uncomment for verbose JavaMail logs in server console, useful for troubleshooting

        try {
            MimeMessage mimeMessage = new MimeMessage(session);
            mimeMessage.setFrom(new InternetAddress(EMAIL_FROM_ADDRESS, EMAIL_FROM_NAME));
            mimeMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            mimeMessage.setSubject(subject);
            mimeMessage.setContent(htmlContent, "text/html; charset=utf-8");

            Transport.send(mimeMessage);
            LOGGER.log(Level.INFO, "Email sent successfully to {0}", recipientEmail);
            return true;
        } catch (MessagingException e) {
            LOGGER.log(Level.SEVERE, "MessagingException while sending email to " + recipientEmail + ". Subject: " + subject, e);
            // Log detailed error from MessagingException
            Exception nextEx = e.getNextException();
            if (nextEx != null) {
                LOGGER.log(Level.SEVERE, "Next exception: ", nextEx);
            }
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "General Exception while sending email to " + recipientEmail + ". Subject: " + subject, e);
            return false;
        }
    }
}