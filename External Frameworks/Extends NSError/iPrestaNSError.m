//
//  iPrestaNSError.m
//  iPresta
//
//  Created by Nacho on 08/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"


@implementation NSError (iPrestaNSError)

- (id)initWithCode:(int)code userInfo:(NSDictionary *)userInfo
{
    self = [[NSError alloc] initWithDomain:@"error" code:code userInfo:userInfo];;
    return self;
}

- (void)manageErrorTo:(id)delegate
{
    NSString *message;
    
    switch ([self code]) {
        case CONNECTION_ERROR: // Error de conexión
            message = NSLocalizedString(@"Problemas conexion", nil);
            break;
        case URLCONNECTION_ERROR: // Error de conexión
            message = NSLocalizedString(@"Problemas conexion", nil);
            break;
        case REQUESTTIMEOUT_ERROR: // Error de tiempo de conexion
            message = NSLocalizedString(@"Problemas conexion", nil);
            break;
        case LOGIN_ERROR: // Error de Login
            message = NSLocalizedString(@"Email password error", nil);
            break;
        case SIGNIN_ERROR: // Error de registro
            message = NSLocalizedString(@"Usuario existente", nil);
            break;
        case REQUESTPASSWORDRESET_ERROR: // Error de recuperación de email
            message = NSLocalizedString(@"Usuario no existente", nil);
            break;
        case NOTCURRENTUSER_ERROR: // Error al modificar un usuario que no es el logueado
            message = NSLocalizedString(@"Usuario no logueado", nil);
            break;
        case EMPTYOBJECTDATA_ERROR: // Error al no encontrar ningun objeto
            message = NSLocalizedString(@"Objeto no encontrado", nil);
            break;
        case REPEATOBJECT_ERROR: // no se ha devuelto ningun objeto de la busqueda
            message = NSLocalizedString(@"Objecto existente", nil);
            break;
        case NOTAUTHENTICATEDUSER_ERROR:
            message = NSLocalizedString(@"Email no autenticado", nil);
            break;
        case FBLOGINUSEREXISTS_ERROR:
            message = [NSString stringWithFormat:NSLocalizedString(@"Cuenta asociada facebook", nil), [self.userInfo objectForKey:@"email"]];
            break;
        case FBLOGIN_ERROR:
            message = NSLocalizedString(@"Cuenta FB no existente", nil);
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}
@end
