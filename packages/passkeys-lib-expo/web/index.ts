import { NativeModule } from "expo";
import {
  type EventEmitter,
  type EventTypeMap,
  CredentialHandlerModule as WebHandler,
} from "passkeys-lib";

export class CredentialHandlerModule extends NativeModule<{
  [K in keyof EventTypeMap]: (event: EventTypeMap[K]) => void;
}> {
  private webModule = WebHandler(this as EventEmitter);
  defaultConfiguration = this.webModule.defaultConfiguraton;
  events = this.webModule.events;
  register = this.webModule.register;
  authenticate = this.webModule.authenticate;
}
