package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.temporal.Temporal;

import java.util.List;
import java.util.UUID;
import java.util.Objects;

import androidx.core.util.ObjectsCompat;

import com.amplifyframework.core.model.AuthStrategy;
import com.amplifyframework.core.model.Model;
import com.amplifyframework.core.model.ModelOperation;
import com.amplifyframework.core.model.annotations.AuthRule;
import com.amplifyframework.core.model.annotations.Index;
import com.amplifyframework.core.model.annotations.ModelConfig;
import com.amplifyframework.core.model.annotations.ModelField;
import com.amplifyframework.core.model.query.predicate.QueryField;

import static com.amplifyframework.core.model.query.predicate.QueryField.field;

/** This is an auto generated class representing the Message type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "Messages", authRules = {
  @AuthRule(allow = AuthStrategy.PRIVATE, operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class Message implements Model {
  public static final QueryField ID = field("Message", "id");
  public static final QueryField CONTENT = field("Message", "content");
  public static final QueryField DATE = field("Message", "date");
  public static final QueryField SENDUSER = field("Message", "senduser");
  public static final QueryField RECEIVEUSER = field("Message", "receiveuser");
  public static final QueryField READED = field("Message", "readed");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="String", isRequired = true) String content;
  private final @ModelField(targetType="String", isRequired = true) String date;
  private final @ModelField(targetType="String", isRequired = true) String senduser;
  private final @ModelField(targetType="String", isRequired = true) String receiveuser;
  private final @ModelField(targetType="String", isRequired = true) String readed;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime createdAt;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime updatedAt;
  public String getId() {
      return id;
  }
  
  public String getContent() {
      return content;
  }
  
  public String getDate() {
      return date;
  }
  
  public String getSenduser() {
      return senduser;
  }
  
  public String getReceiveuser() {
      return receiveuser;
  }
  
  public String getReaded() {
      return readed;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private Message(String id, String content, String date, String senduser, String receiveuser, String readed) {
    this.id = id;
    this.content = content;
    this.date = date;
    this.senduser = senduser;
    this.receiveuser = receiveuser;
    this.readed = readed;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      Message message = (Message) obj;
      return ObjectsCompat.equals(getId(), message.getId()) &&
              ObjectsCompat.equals(getContent(), message.getContent()) &&
              ObjectsCompat.equals(getDate(), message.getDate()) &&
              ObjectsCompat.equals(getSenduser(), message.getSenduser()) &&
              ObjectsCompat.equals(getReceiveuser(), message.getReceiveuser()) &&
              ObjectsCompat.equals(getReaded(), message.getReaded()) &&
              ObjectsCompat.equals(getCreatedAt(), message.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), message.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getContent())
      .append(getDate())
      .append(getSenduser())
      .append(getReceiveuser())
      .append(getReaded())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("Message {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("content=" + String.valueOf(getContent()) + ", ")
      .append("date=" + String.valueOf(getDate()) + ", ")
      .append("senduser=" + String.valueOf(getSenduser()) + ", ")
      .append("receiveuser=" + String.valueOf(getReceiveuser()) + ", ")
      .append("readed=" + String.valueOf(getReaded()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static ContentStep builder() {
      return new Builder();
  }
  
  /**
   * WARNING: This method should not be used to build an instance of this object for a CREATE mutation.
   * This is a convenience method to return an instance of the object with only its ID populated
   * to be used in the context of a parameter in a delete mutation or referencing a foreign key
   * in a relationship.
   * @param id the id of the existing item this instance will represent
   * @return an instance of this model with only ID populated
   */
  public static Message justId(String id) {
    return new Message(
      id,
      null,
      null,
      null,
      null,
      null
    );
  }
  
  public CopyOfBuilder copyOfBuilder() {
    return new CopyOfBuilder(id,
      content,
      date,
      senduser,
      receiveuser,
      readed);
  }
  public interface ContentStep {
    DateStep content(String content);
  }
  

  public interface DateStep {
    SenduserStep date(String date);
  }
  

  public interface SenduserStep {
    ReceiveuserStep senduser(String senduser);
  }
  

  public interface ReceiveuserStep {
    ReadedStep receiveuser(String receiveuser);
  }
  

  public interface ReadedStep {
    BuildStep readed(String readed);
  }
  

  public interface BuildStep {
    Message build();
    BuildStep id(String id);
  }
  

  public static class Builder implements ContentStep, DateStep, SenduserStep, ReceiveuserStep, ReadedStep, BuildStep {
    private String id;
    private String content;
    private String date;
    private String senduser;
    private String receiveuser;
    private String readed;
    @Override
     public Message build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new Message(
          id,
          content,
          date,
          senduser,
          receiveuser,
          readed);
    }
    
    @Override
     public DateStep content(String content) {
        Objects.requireNonNull(content);
        this.content = content;
        return this;
    }
    
    @Override
     public SenduserStep date(String date) {
        Objects.requireNonNull(date);
        this.date = date;
        return this;
    }
    
    @Override
     public ReceiveuserStep senduser(String senduser) {
        Objects.requireNonNull(senduser);
        this.senduser = senduser;
        return this;
    }
    
    @Override
     public ReadedStep receiveuser(String receiveuser) {
        Objects.requireNonNull(receiveuser);
        this.receiveuser = receiveuser;
        return this;
    }
    
    @Override
     public BuildStep readed(String readed) {
        Objects.requireNonNull(readed);
        this.readed = readed;
        return this;
    }
    
    /**
     * @param id id
     * @return Current Builder instance, for fluent method chaining
     */
    public BuildStep id(String id) {
        this.id = id;
        return this;
    }
  }
  

  public final class CopyOfBuilder extends Builder {
    private CopyOfBuilder(String id, String content, String date, String senduser, String receiveuser, String readed) {
      super.id(id);
      super.content(content)
        .date(date)
        .senduser(senduser)
        .receiveuser(receiveuser)
        .readed(readed);
    }
    
    @Override
     public CopyOfBuilder content(String content) {
      return (CopyOfBuilder) super.content(content);
    }
    
    @Override
     public CopyOfBuilder date(String date) {
      return (CopyOfBuilder) super.date(date);
    }
    
    @Override
     public CopyOfBuilder senduser(String senduser) {
      return (CopyOfBuilder) super.senduser(senduser);
    }
    
    @Override
     public CopyOfBuilder receiveuser(String receiveuser) {
      return (CopyOfBuilder) super.receiveuser(receiveuser);
    }
    
    @Override
     public CopyOfBuilder readed(String readed) {
      return (CopyOfBuilder) super.readed(readed);
    }
  }
  
}
