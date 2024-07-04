<?php

namespace Simonetti\Helpers\Tests;

use ReflectionClass;
use ReflectionException;

trait SetDataTrait
{
    /**
     * @template T of Object
     * @param T $entity
     * @param array<string,mixed> $data
     * @throws ReflectionException
     * @return T
     */
    private static function setObject(object $entity, array $data): object
    {
        $reflectionClass = new ReflectionClass(get_class($entity));

        foreach ($data as $key => $value) {
            self::setPropertyValueOnClass(
                entity: $entity,
                prop: $key,
                value: $value,
                reflectionClass: $reflectionClass,
            );
        }

        return $entity;
    }

    /**
     * @template T of Object
     * @param T $entity
     * @param ReflectionClass<T> $reflectionClass
     * @throws ReflectionException
     * @return null|void
     */
    private static function setPropertyValueOnClass(
        object $entity,
        string $prop,
        $value,
        ReflectionClass $reflectionClass,
        bool $useMethods = true
    ) {
        try {
            $method = 'set' . ucfirst($prop);
            if ($reflectionClass->hasMethod($method) && $useMethods) {
                $method = $reflectionClass->getMethod($method);
                if (1 === $method->getNumberOfRequiredParameters()) {
                    $method->setAccessible(true);
                    $method->invoke($entity, $value);

                    return;
                }
            }

            if ($reflectionClass->hasProperty($prop)) {
                $prop = $reflectionClass->getProperty($prop);
                $prop->setAccessible(true);
                $prop->setValue($entity, $value);

                return;
            }

            throw new ReflectionException(sprintf(
                'No property %s or method %s found on class %s',
                $prop,
                $method,
                get_class($entity),
            ));
        } catch (ReflectionException $exception) {
            $parentClass = $reflectionClass->getParentClass();
            if (false === $parentClass) {
                throw $exception;
            }
            self::setPropertyValueOnClass($entity, $prop, $value, $parentClass);
        }
    }
}
